library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

ui <- bslib::page_sidebar(
  title = "Basic shinymodist input",
  sidebar = bslib::sidebar(
    width = 320,
    modist_input(
      "dist",
      family = "normal",
      value = list(mu = 0, sigma = 1)
    ),
    actionButton("set_value", "Set mu = 1, sigma = 2"),
    tags$small(
      class = "text-body-secondary",
      paste("shinymodist", as.character(packageVersion("shinymodist")))
    )
  ),
  bslib::card(
    bslib::card_header("Reactive value"),
    verbatimTextOutput("value")
  )
)

server <- function(input, output, session) {
  observeEvent(input$set_value, {
    update_modist_input(
      "dist",
      value = list(mu = 1, sigma = 2)
    )
  })

  output$value <- renderPrint(input$dist)
}

shinyApp(ui, server)
