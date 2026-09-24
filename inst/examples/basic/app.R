library(shiny)
library(shinymodist)

ui <- fluidPage(
  h3("Basic shinymodist input"),
  modist_input(
    "dist",
    family = "normal",
    value = list(mu = 0, sigma = 1)
  ),
  actionButton("set_value", "Set mu = 1, sigma = 2"),
  h4("Reactive value"),
  verbatimTextOutput("value")
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
