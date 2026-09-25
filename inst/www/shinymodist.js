(function () {
  "use strict";

  const factories = {
    normal: window.modist.normal,
    beta: window.modist.beta,
    gamma: window.modist.gamma,
    studentt: window.modist.studentT,
    exponential: window.modist.exponential,
    halfnormal: window.modist.halfNormal,
    lognormal: window.modist.logNormal,
    cauchy: window.modist.cauchy,
    laplace: window.modist.laplace,
    logistic: window.modist.logistic,
    weibull: window.modist.weibull,
    halfstudentt: window.modist.halfStudentT,
    chisquared: window.modist.chiSquared,
    inversegamma: window.modist.inverseGamma,
    kumaraswamy: window.modist.kumaraswamy,
  };

  function readConfig(el) {
    return JSON.parse(el.getAttribute("data-shinymodist-config"));
  }

  function setPresentation(el, config) {
    el.dataset.style = config.style || "minimal";

    if (config.grid !== null && config.grid !== undefined) {
      el.dataset.grid = String(Boolean(config.grid));
    }

    if (config.ticks !== null && config.ticks !== undefined) {
      el.dataset.ticks = String(Boolean(config.ticks));
    }

    if (Array.isArray(config.domain)) {
      el.dataset.fixedDomain = "true";
    }
  }

  function applyMinimalLabels(el, config) {
    if ((config.style || "minimal") !== "minimal" || config.family !== "normal") {
      return;
    }

    el.querySelectorAll(".mlabeltxt").forEach(function (label) {
      if (label.textContent.trim().toLowerCase() === "mean") {
        label.textContent = "μ";
      }
    });
  }

  function observeMinimalLabels(el, config, target) {
    if ((config.style || "minimal") !== "minimal" || config.family !== "normal") {
      return;
    }

    const observer = new MutationObserver(function () {
      applyMinimalLabels(el, config);
    });

    observer.observe(target, {
      childList: true,
      subtree: true,
      characterData: true,
    });

    el._shinymodistLabelObserver = observer;
  }

  function mount(el) {
    if (el._shinymodist) return;

    const config = readConfig(el);
    const factory = factories[config.family];

    if (!factory) {
      throw new Error("Unsupported shinymodist family: " + config.family);
    }

    setPresentation(el, config);

    const target = document.createElement("div");
    target.className = "shinymodist-mount";
    el.appendChild(target);

    const options = Array.isArray(config.domain)
      ? { domain: config.domain }
      : {};

    const instance = factory(target, config.value || {}, options);
    applyMinimalLabels(el, config);
    observeMinimalLabels(el, config, target);

    el._shinymodist = instance;
    el._shinymodistFamily = config.family;
    el._shinymodistValue = {
      family: config.family,
      ...instance.params,
    };

    instance.onChange(function (params) {
      applyMinimalLabels(el, config);
      el._shinymodistValue = {
        family: config.family,
        ...params,
      };
      window.jQuery(el).trigger(
        "shinymodist:change",
        [Boolean(el._shinymodistServerUpdate)]
      );
    });
  }

  const binding = new window.Shiny.InputBinding();

  window.jQuery.extend(binding, {
    find: function (scope) {
      return window.jQuery(scope).find(".shinymodist-input");
    },

    initialize: function (el) {
      mount(el);
    },

    getValue: function (el) {
      mount(el);
      return el._shinymodistValue;
    },

    subscribe: function (el, callback) {
      window.jQuery(el).on(
        "shinymodist:change.shinymodist",
        function (event, fromServer) {
          callback(!fromServer);
        }
      );
    },

    getRatePolicy: function () {
      return {
        policy: "debounce",
        delay: 250,
      };
    },

    unsubscribe: function (el) {
      window.jQuery(el).off(".shinymodist");
    },

    receiveMessage: function (el, data) {
      mount(el);
      if (data.value) {
        el._shinymodistServerUpdate = true;
        try {
          el._shinymodist.set(data.value);
          el._shinymodistValue = {
            family: el._shinymodistFamily,
            ...el._shinymodist.params,
          };
          applyMinimalLabels(el, readConfig(el));
        } finally {
          el._shinymodistServerUpdate = false;
        }
      }
    },
  });

  window.Shiny.inputBindings.register(binding, "shinymodist.input");
})();
