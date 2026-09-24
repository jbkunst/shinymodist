(function () {
  "use strict";

  const factories = {
    normal: window.modist.normal,
    beta: window.modist.beta,
    gamma: window.modist.gamma,
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

    el._shinymodist = instance;
    el._shinymodistFamily = config.family;
    el._shinymodistValue = {
      family: config.family,
      ...instance.params,
    };

    instance.onChange(function (params) {
      el._shinymodistValue = {
        family: config.family,
        ...params,
      };
      window.jQuery(el).trigger("shinymodist:change");
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
      window.jQuery(el).on("shinymodist:change.shinymodist", function () {
        callback();
      });
    },

    unsubscribe: function (el) {
      window.jQuery(el).off(".shinymodist");
    },

    receiveMessage: function (el, data) {
      mount(el);
      if (data.value) {
        el._shinymodist.set(data.value);
      }
    },
  });

  window.Shiny.inputBindings.register(binding, "shinymodist.input");
})();
