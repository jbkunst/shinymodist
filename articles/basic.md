# Basic input

## Live demo

[Open this example in
Shinylive](https://jkunst.com/shinymodist/demos/basic/)

The app runs entirely in the browser with webR; no local R installation
is required for the demo.

`shinymodist` exposes an interactive distribution as a regular Shiny
input.

``` r

library(shiny)
library(shinymodist)

ui <- bslib::page_sidebar(
  title = "Basic shinymodist input",
  sidebar = bslib::sidebar(
    modist_input(
      "dist",
      family = "normal",
      value = list(mu = 0, sigma = 1)
    )
  ),
  bslib::card(
    bslib::card_header("Reactive value"),
    verbatimTextOutput("value")
  )
)

server <- function(input, output, session) {
  output$value <- renderPrint(input$dist)
}

shinyApp(ui, server)
```

The complete runnable app ships with the package:

``` r

shiny::runApp(system.file("examples/basic", package = "shinymodist"))
```

Server-side changes use
[`update_modist_input()`](https://jkunst.com/shinymodist/reference/update_modist_input.md):

``` r

update_modist_input(
  "dist",
  value = list(mu = 1, sigma = 2)
)
```
