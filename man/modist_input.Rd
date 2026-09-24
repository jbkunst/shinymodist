\name{modist_input}
\alias{modist_input}
\title{Interactive distribution input}
\usage{
modist_input(
  input_id,
  family = "normal",
  value = NULL,
  domain = NULL,
  style = c("minimal", "modist"),
  ticks = NULL,
  grid = NULL
)
}
\arguments{
\item{input_id}{Shiny input id.}
\item{family}{Distribution family. Currently \code{"normal"}, \code{"beta"}, or \code{"gamma"}.}
\item{value}{Named list of initial distribution parameters. Missing parameters use family defaults.}
\item{domain}{Optional numeric vector of length two giving a fixed visible domain.}
\item{style}{Visual preset: \code{"minimal"} or \code{"modist"}.}
\item{ticks}{Optional logical. \code{NULL} inherits the selected style.}
\item{grid}{Optional logical. \code{NULL} inherits the selected style.}
}
\value{A Shiny input tag.}
\description{
Creates a compact Shiny input for interactively shaping a probability distribution.
The input value contains the family and canonical parameters.
}
\examples{
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
}
