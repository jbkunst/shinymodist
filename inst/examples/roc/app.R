library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

score_domain <- c(-5, 5)

negative_color <- "#60A5FA"
positive_color <- "#2563EB"
threshold_color <- "#D9A441"
reference_color <- "#CBD5E1"

ui <- bslib::page_sidebar(
  title = "ROC curve",
  sidebar = bslib::sidebar(
    width = 320,
    "Positive distribution",
    modist_input(
      "positive",
      value = list(mu = 1.25, sigma = 1.5),
      domain = score_domain
    ),
    "Negative distribution",
    modist_input(
      "negative",
      value = list(mu = -1.25, sigma = 1.5),
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
    y_max <- max(y_neg, y_pos)

    plot(
      x, y_neg,
      type = "n",
      xlab = "Score",
      ylab = "Density",
      ylim = c(0, y_max * 1.08),
      bty = "n"
    )

    polygon(
      c(x[[1]], x, x[[length(x)]]),
      c(0, y_neg, 0),
      border = NA,
      col = grDevices::adjustcolor(negative_color, alpha.f = 0.22)
    )
    polygon(
      c(x[[1]], x, x[[length(x)]]),
      c(0, y_pos, 0),
      border = NA,
      col = grDevices::adjustcolor(positive_color, alpha.f = 0.20)
    )

    lines(x, y_neg, col = negative_color, lwd = 2.5)
    lines(x, y_pos, col = positive_color, lwd = 2.5)
    abline(
      v = input$threshold,
      col = threshold_color,
      lty = 2,
      lwd = 2
    )

    legend(
      "topright",
      legend = c("Negative", "Positive", "Threshold"),
      col = c(negative_color, positive_color, threshold_color),
      lty = c(1, 1, 2),
      lwd = c(2.5, 2.5, 2),
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
      type = "n",
      xlim = c(0, 1),
      ylim = c(0, 1),
      xlab = "False positive rate",
      ylab = "True positive rate",
      bty = "n"
    )
    abline(0, 1, col = reference_color, lty = 3, lwd = 2)
    lines(fpr, tpr, col = positive_color, lwd = 3)

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

    points(
      current_fpr,
      current_tpr,
      pch = 21,
      cex = 1.4,
      col = threshold_color,
      bg = threshold_color
    )
  })
}

shinyApp(ui, server)
