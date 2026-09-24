library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

theme <- bslib::bs_theme(
  version = 5,
  primary = "#6f42c1"
)

ui <- bslib::page_fluid(
  theme = theme,
  h2("Styles and bslib theming"),
  p("The minimal style follows the bslib primary color. The modist style keeps the upstream look."),
  bslib::layout_columns(
    bslib::card(
      bslib::card_header("Minimal (default)"),
      modist_input(
        "minimal",
        value = list(mu = 0, sigma = 1)
      )
    ),
    bslib::card(
      bslib::card_header("Original modist"),
      modist_input(
        "original",
        value = list(mu = 0, sigma = 1),
        style = "modist"
      )
    ),
    bslib::card(
      bslib::card_header("Minimal with grid"),
      modist_input(
        "grid",
        value = list(mu = 0, sigma = 1),
        grid = TRUE
      )
    )
  ),
  h4("Reactive values"),
  verbatimTextOutput("values")
)

server <- function(input, output, session) {
  output$values <- renderPrint(
    list(
      minimal = input$minimal,
      original = input$original,
      grid = input$grid
    )
  )
}

shinyApp(ui, server)
