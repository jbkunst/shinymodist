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
    class = "gallery-card",
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
  padding = "0.45rem",
  gap = 0,
  tags$head(
    tags$style(HTML("
      .gallery-card {
        border-radius: 0.4rem;
      }

      .gallery-card > .card-header {
        padding: 0.35rem 0.55rem;
        font-size: 0.85rem;
        font-weight: 500;
        line-height: 1.15;
      }
    "))
  ),
  do.call(
    bslib::layout_column_wrap,
    c(
      cards,
      list(
        width = 1 / 4,
        heights_equal = "all",
        fill = TRUE,
        fillable = TRUE,
        height = "100%",
        gap = "0.45rem"
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
