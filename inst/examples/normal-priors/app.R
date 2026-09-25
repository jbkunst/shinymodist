library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

ui <- bslib::page_sidebar(
  title = "Bayesian normal model",
  sidebar = bslib::sidebar(
    width = 360,
    h5("Prior for the mean"),
    modist_input(
      "mu_prior",
      family = "normal",
      value = list(mu = 0, sigma = 1),
      domain = c(-4, 4)
    ),
    hr(),
    h5("Prior for the variance"),
    modist_input(
      "variance_prior",
      family = "inversegamma",
      value = list(alpha = 3, beta = 2),
      domain = c(0, 4)
    )
  ),
  bslib::card(
    bslib::card_header("Implied prior predictive"),
    p(
      "μ ~ Normal(m₀, s₀), σ² ~ Inverse-Gamma(α, β), ",
      "y | μ, σ² ~ Normal(μ, σ²)."
    ),
    plotOutput("predictive", height = "360px")
  )
)

server <- function(input, output, session) {
  output$predictive <- renderPlot({
    mu_prior <- input$mu_prior
    variance_prior <- input$variance_prior
    req(mu_prior, variance_prior)

    # Integrate the Normal prior for mu analytically, then approximate the
    # remaining Inverse-Gamma mixture with deterministic quantile points.
    probs <- (seq_len(240) - 0.5) / 240
    variance <- 1 / qgamma(
      1 - probs,
      shape = variance_prior$alpha,
      rate = variance_prior$beta
    )

    variance_90 <- 1 / qgamma(
      0.10,
      shape = variance_prior$alpha,
      rate = variance_prior$beta
    )
    predictive_sd <- sqrt(mu_prior$sigma^2 + variance_90)

    x <- seq(
      mu_prior$mu - 4 * predictive_sd,
      mu_prior$mu + 4 * predictive_sd,
      length.out = 450
    )

    density_matrix <- vapply(
      variance,
      function(v) {
        dnorm(
          x,
          mean = mu_prior$mu,
          sd = sqrt(mu_prior$sigma^2 + v)
        )
      },
      numeric(length(x))
    )

    density <- rowMeans(density_matrix)

    plot(
      x,
      density,
      type = "l",
      lwd = 3,
      xlab = "y",
      ylab = "Prior predictive density",
      bty = "n"
    )
    abline(v = mu_prior$mu, lty = 3)
  })
}

shinyApp(ui, server)
