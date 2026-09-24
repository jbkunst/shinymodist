library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

score_domain <- c(-5, 5)

ui <- bslib::page_sidebar(
  title = "ROC curve",
  sidebar = bslib::sidebar(
    width = 320,
    "Positive distribution",
    modist_input(
      "positive",
      value = list(mu = 1, sigma = 1),
      domain = score_domain
    ),
    "Negative distribution",
    modist_input(
      "negative",
      value = list(mu = -1, sigma = 1),
      domain = score_domain
    ),
    sliderInput(
      "threshold",
      "Threshold",
      min = score_domain[[1]],
      max = score_domain[[2]],
      value = 0,
      step = 0.1,
      ticks = FALSE
    )
  ),
  bslib::layout_columns(
    bslib::card(
      bslib::card_header("Score distributions"),
      plotOutput("distributions")
    ),
    bslib::card(
      bslib::card_header("ROC curve"),
      plotOutput("roc")
    )
  )
)

server <- function(input, output, session) {
  output$distributions <- renderPlot({
    pos <- input$positive
    neg <- input$negative
    req(pos, neg)

    x <- seq(score_domain[[1]], score_domain[[2]], length.out = 400)
    y_neg <- dnorm(x, mean = neg$mu, sd = neg$sigma)
    y_pos <- dnorm(x, mean = pos$mu, sd = pos$sigma)

    plot(
      x, y_neg,
      type = "l",
      lwd = 2,
      xlab = "Score",
      ylab = "Density",
      ylim = c(0, max(y_neg, y_pos))
    )
    lines(x, y_pos, lwd = 2, lty = 2)
    abline(v = input$threshold, lty = 3)
    legend(
      "topright",
      legend = c("Negative", "Positive", "Threshold"),
      lty = c(1, 2, 3),
      lwd = c(2, 2, 1),
      bty = "n"
    )
  })

  output$roc <- renderPlot({
    pos <- input$positive
    neg <- input$negative
    req(pos, neg)

    threshold <- seq(
      score_domain[[2]],
      score_domain[[1]],
      length.out = 400
    )

    fpr <- 1 - pnorm(threshold, mean = neg$mu, sd = neg$sigma)
    tpr <- 1 - pnorm(threshold, mean = pos$mu, sd = pos$sigma)

    plot(
      fpr, tpr,
      type = "l",
      lwd = 2,
      xlim = c(0, 1),
      ylim = c(0, 1),
      xlab = "False positive rate",
      ylab = "True positive rate"
    )
    abline(0, 1, lty = 3)

    current_fpr <- 1 - pnorm(
      input$threshold,
      mean = neg$mu,
      sd = neg$sigma
    )
    current_tpr <- 1 - pnorm(
      input$threshold,
      mean = pos$mu,
      sd = pos$sigma
    )

    points(current_fpr, current_tpr, pch = 19)
  })
}

shinyApp(ui, server)
