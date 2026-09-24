library(shiny)
library(shinymodist)

ui <- fluidPage(
  h3("Beta-Binomial prior elicitation"),
  fluidRow(
    column(
      width = 4,
      modist_input(
        "prior",
        family = "beta",
        value = list(alpha = 2, beta = 2)
      ),
      sliderInput("n", "Trials", min = 1, max = 100, value = 20),
      sliderInput("x", "Successes", min = 0, max = 20, value = 12),
      verbatimTextOutput("posterior")
    ),
    column(
      width = 8,
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$n, {
    updateSliderInput(
      session,
      "x",
      max = input$n,
      value = min(input$x, input$n)
    )
  })

  posterior <- reactive({
    prior <- input$prior
    req(prior)

    list(
      alpha = prior$alpha + input$x,
      beta = prior$beta + input$n - input$x
    )
  })

  output$posterior <- renderPrint({
    post <- posterior()
    c(
      posterior_alpha = post$alpha,
      posterior_beta = post$beta
    )
  })

  output$plot <- renderPlot({
    prior <- input$prior
    post <- posterior()
    req(prior, post)

    p <- seq(0, 1, length.out = 400)
    y_prior <- dbeta(p, prior$alpha, prior$beta)
    y_post <- dbeta(p, post$alpha, post$beta)

    plot(
      p, y_prior,
      type = "l",
      lwd = 2,
      xlab = "Probability",
      ylab = "Density",
      ylim = c(0, max(y_prior, y_post))
    )
    lines(p, y_post, lwd = 2, lty = 2)
    legend(
      "topright",
      legend = c("Prior", "Posterior"),
      lty = c(1, 2),
      lwd = 2,
      bty = "n"
    )
  })
}

shinyApp(ui, server)
