library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

families <- c(
  "normal",
  "beta",
  "gamma",
  "studentt",
  "exponential",
  "halfnormal",
  "lognormal",
  "cauchy",
  "laplace",
  "logistic",
  "weibull",
  "halfstudentt",
  "chisquared",
  "inversegamma",
  "kumaraswamy"
)

family_label <- function(x) {
  labels <- c(
    studentt = "Student t",
    halfnormal = "Half Normal",
    lognormal = "Log Normal",
    halfstudentt = "Half Student t",
    chisquared = "Chi-squared",
    inversegamma = "Inverse Gamma"
  )

  if (x %in% names(labels)) labels[[x]] else tools::toTitleCase(x)
}

cards <- lapply(families, function(family) {
  bslib::card(
    fill = FALSE,
    wrapper = function(...) {
      bslib::card_body(..., fillable = FALSE, fill = FALSE)
    },
    bslib::card_header(family_label(family)),
    modist_input(
      paste0("dist_", family),
      family = family
    )
  )
})

theme <- bslib::bs_theme(
  version = 5,
  primary = "#6f42c1"
)

ui <- bslib::page_sidebar(
  title = "shinymodist gallery",
  theme = theme,
  sidebar = bslib::sidebar(
    width = 300,
    h5("Narrow sidebar"),
    p("Same input at sidebar width."),
    modist_input(
      "sidebar_normal",
      family = "normal",
      value = list(mu = 0, sigma = 1),
      domain = c(-4, 4)
    ),
    hr(),
    h5("Fixed height"),
    p("Optional height for constrained layouts."),
    modist_input(
      "sidebar_fixed",
      family = "normal",
      value = list(mu = 0, sigma = 1),
      domain = c(-4, 4),
      height = "180px"
    ),
    hr(),
    h5("Original modist"),
    modist_input(
      "sidebar_modist",
      family = "normal",
      value = list(mu = 0, sigma = 1),
      style = "modist",
      domain = c(-4, 4)
    )
  ),
  p(
    "All upstream modist families using the default minimal style. ",
    "Labels adapt to narrow containers; the component height follows its available width."
  ),
  do.call(
    bslib::layout_columns,
    c(
      cards,
      list(
        col_widths = c(4, 4, 4),
        fill = FALSE,
        fillable = FALSE
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
