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
    fill = TRUE,
    bslib::card_header(family_label(family)),
    modist_input(
      paste0("dist_", family),
      family = family,
      height = "100%"
    )
  )
})

theme <- bslib::bs_theme(
  version = 5,
  primary = "#6f42c1"
)

ui <- bslib::page_fillable(
  title = "shinymodist gallery",
  theme = theme,
  padding = 0,
  gap = 0,
  do.call(
    bslib::layout_columns,
    c(
      cards,
      list(
        col_widths = 3,
        row_heights = rep(1, 4),
        gap = 0,
        fill = TRUE,
        fillable = TRUE
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
