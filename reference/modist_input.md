# Interactive distribution input

Creates a compact Shiny input for interactively shaping a probability
distribution. The input value contains the family and canonical
parameters.

## Usage

``` r
modist_input(
  input_id,
  family = "normal",
  value = NULL,
  domain = NULL,
  style = c("minimal", "modist"),
  ticks = NULL,
  grid = NULL
)
```

## Arguments

- input_id:

  Shiny input id.

- family:

  Distribution family. Currently `"normal"`, `"beta"`, or `"gamma"`.

- value:

  Named list of initial distribution parameters. Missing parameters use
  family defaults.

- domain:

  Optional numeric vector of length two giving a fixed visible domain.

- style:

  Visual preset: `"minimal"` or `"modist"`.

- ticks:

  Optional logical. `NULL` inherits the selected style.

- grid:

  Optional logical. `NULL` inherits the selected style.

## Value

A Shiny input tag.

## Examples

``` r
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    modist_input("dist", value = list(mu = 0, sigma = 1)),
    verbatimTextOutput("value")
  )
  server <- function(input, output, session) {
    output$value <- renderPrint(input$dist)
  }
  shinyApp(ui, server)
}
```
