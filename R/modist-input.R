#' Interactive distribution input
#'
#' Creates a compact Shiny input for interactively shaping a probability
#' distribution. The input value is a named list containing `family` and the
#' canonical parameters for that family.
#'
#' @param input_id Shiny input id.
#' @param family Distribution family supported by modist.
#' @param value Named list of initial distribution parameters. Missing
#'   parameters use the family defaults.
#' @param domain Optional numeric vector of length two giving a fixed visible
#'   domain. `NULL` keeps modist's automatic domain behavior.
#' @param style Visual preset: `"minimal"` (default) or `"modist"`.
#' @param ticks Optional logical. `NULL` inherits the selected style.
#' @param grid Optional logical. `NULL` inherits the selected style.
#'
#' @return A Shiny input tag.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     modist_input("dist", value = list(mu = 0, sigma = 1)),
#'     verbatimTextOutput("value")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$value <- renderPrint(input$dist)
#'   }
#'
#'   shinyApp(ui, server)
#' }
modist_input <- function(
  input_id,
  family = "normal",
  value = NULL,
  domain = NULL,
  style = c("minimal", "modist"),
  ticks = NULL,
  grid = NULL
) {
  family <- match.arg(family, names(modist_families()))
  style <- match.arg(style)

  value <- normalize_modist_value(family, value)
  domain <- normalize_modist_domain(domain)
  ticks <- normalize_optional_flag(ticks, "ticks")
  grid <- normalize_optional_flag(grid, "grid")

  config <- list(
    family = family,
    value = value,
    domain = domain,
    style = style,
    ticks = ticks,
    grid = grid
  )

  tag <- htmltools::div(
    id = input_id,
    class = "shinymodist-input",
    role = "group",
    `data-shinymodist-config` = jsonlite::toJSON(
      config,
      auto_unbox = TRUE,
      null = "null",
      digits = NA
    )
  )

  htmltools::attachDependencies(tag, shinymodist_dependency())
}

#' Update an interactive distribution input
#'
#' Updates one or more parameter values of an existing [modist_input()] from
#' the Shiny server.
#'
#' @param input_id Id of the input to update.
#' @param value Named list of parameter values to update.
#' @param session The Shiny session.
#'
#' @return Invisibly returns `NULL`.
#' @export
update_modist_input <- function(
  input_id,
  value,
  session = shiny::getDefaultReactiveDomain()
) {
  if (is.null(session)) {
    stop("update_modist_input() must be called from an active Shiny session.", call. = FALSE)
  }

  validate_update_value(value)
  session$sendInputMessage(input_id, list(value = value))
  invisible(NULL)
}

shinymodist_dependency <- function() {
  htmltools::htmlDependency(
    name = "shinymodist",
    version = "0.0.0.9002",
    src = c(file = "www"),
    package = "shinymodist",
    script = c("modist.js", "shinymodist.js"),
    stylesheet = "shinymodist.css"
  )
}

modist_families <- function() {
  list(
    normal = list(
      defaults = list(mu = 0, sigma = 1),
      positive = "sigma"
    ),
    beta = list(
      defaults = list(alpha = 2, beta = 2),
      positive = c("alpha", "beta")
    ),
    gamma = list(
      defaults = list(alpha = 2, beta = 2),
      positive = c("alpha", "beta")
    ),
    studentt = list(
      defaults = list(mu = 0, sigma = 1, nu = 5),
      positive = c("sigma", "nu")
    ),
    exponential = list(
      defaults = list(lam = 1),
      positive = "lam"
    ),
    halfnormal = list(
      defaults = list(sigma = 1),
      positive = "sigma"
    ),
    lognormal = list(
      defaults = list(mu = 0, sigma = 1),
      positive = "sigma"
    ),
    cauchy = list(
      defaults = list(alpha = 0, beta = 1),
      positive = "beta"
    ),
    laplace = list(
      defaults = list(mu = 0, b = 1),
      positive = "b"
    ),
    logistic = list(
      defaults = list(mu = 0, s = 1),
      positive = "s"
    ),
    weibull = list(
      defaults = list(alpha = 2, beta = 1),
      positive = c("alpha", "beta")
    ),
    halfstudentt = list(
      defaults = list(nu = 5, sigma = 1),
      positive = c("nu", "sigma")
    ),
    chisquared = list(
      defaults = list(nu = 3),
      positive = "nu"
    ),
    inversegamma = list(
      defaults = list(alpha = 3, beta = 1),
      positive = c("alpha", "beta")
    ),
    kumaraswamy = list(
      defaults = list(a = 2, b = 2),
      positive = c("a", "b")
    )
  )
}

normalize_modist_value <- function(family, value) {
  spec <- modist_families()[[family]]
  defaults <- spec$defaults

  if (is.null(value)) {
    return(defaults)
  }

  if (!is.list(value) || is.null(names(value)) || any(names(value) == "")) {
    stop("value must be a named list.", call. = FALSE)
  }

  unknown <- setdiff(names(value), names(defaults))
  if (length(unknown)) {
    stop(
      sprintf(
        "Unknown parameter%s for %s: %s.",
        if (length(unknown) == 1) "" else "s",
        family,
        paste(unknown, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  validate_numeric_params(value)
  out <- utils::modifyList(defaults, value)

  bad_positive <- spec$positive[vapply(
    spec$positive,
    function(name) out[[name]] <= 0,
    logical(1)
  )]

  if (length(bad_positive)) {
    stop(
      sprintf(
        "%s parameter%s must be greater than 0: %s.",
        family,
        if (length(bad_positive) == 1) "" else "s",
        paste(bad_positive, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  out
}

normalize_modist_domain <- function(domain) {
  if (is.null(domain)) {
    return(NULL)
  }

  if (!is.numeric(domain) || length(domain) != 2 || any(!is.finite(domain))) {
    stop("domain must be NULL or two finite numbers.", call. = FALSE)
  }

  if (domain[[1]] >= domain[[2]]) {
    stop("domain must be strictly increasing.", call. = FALSE)
  }

  as.numeric(domain)
}

normalize_optional_flag <- function(x, name) {
  if (is.null(x)) {
    return(NULL)
  }

  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    stop(sprintf("%s must be NULL, TRUE, or FALSE.", name), call. = FALSE)
  }

  x
}

validate_update_value <- function(value) {
  if (!is.list(value) || is.null(names(value)) || any(names(value) == "")) {
    stop("value must be a named list.", call. = FALSE)
  }

  validate_numeric_params(value)
  invisible(value)
}

validate_numeric_params <- function(value) {
  for (name in names(value)) {
    x <- value[[name]]
    if (!is.numeric(x) || length(x) != 1 || !is.finite(x)) {
      stop(sprintf("value$%s must be one finite number.", name), call. = FALSE)
    }
  }

  invisible(value)
}
