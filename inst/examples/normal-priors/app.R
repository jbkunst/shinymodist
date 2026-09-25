library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

observations <- c(
  1.8, 0.9, 1.4, 1.2, 1.6, 0.8,
  1.1, 1.5, 1.0, 1.3, 1.7, 0.7
)

inverse_gamma_density <- function(x, alpha, beta) {
  exp(
    alpha * log(beta) -
      lgamma(alpha) -
      (alpha + 1) * log(x) -
      beta / x
  )
}

inverse_gamma_quantile <- function(p, alpha, beta) {
  1 / qgamma(1 - p, shape = alpha, rate = beta)
}

trapezoid_weights <- function(x) {
  n <- length(x)

  c(
    (x[[2]] - x[[1]]) / 2,
    (x[3:n] - x[1:(n - 2)]) / 2,
    (x[[n]] - x[[n - 1]]) / 2
  )
}

ui <- bslib::page_sidebar(
  title = "Bayesian normal model",
  sidebar = bslib::sidebar(
    width = 360,
    h5("Prior for the mean"),
    modist_input(
      "mu_prior",
      family = "normal",
      value = list(mu = 0, sigma = 1.25),
      domain = c(-4, 4)
    ),
    hr(),
    h5("Prior for the variance"),
    modist_input(
      "variance_prior",
      family = "inversegamma",
      value = list(alpha = 3, beta = 1),
      domain = c(0, 3)
    ),
    hr(),
    div(
      style = "max-width: 220px;",
      sliderInput(
        "n_obs",
        "Observed data",
        min = 1,
        max = length(observations),
        value = 4,
        step = 1,
        ticks = FALSE,
        width = "100%"
      )
    ),
    textOutput("data_summary")
  ),
  bslib::card(
    fill = FALSE,
    bslib::card_header("Mean: prior → posterior"),
    plotOutput("mu_plot", height = "280px")
  ),
  bslib::card(
    fill = FALSE,
    bslib::card_header("Variance: prior → posterior"),
    plotOutput("variance_plot", height = "280px")
  )
)

server <- function(input, output, session) {
  posterior <- reactive({
    mu_prior <- input$mu_prior
    variance_prior <- input$variance_prior
    req(mu_prior, variance_prior, input$n_obs)

    y <- observations[seq_len(input$n_obs)]

    mu_lo <- min(
      mu_prior$mu - 4 * mu_prior$sigma,
      min(y) - 1
    )
    mu_hi <- max(
      mu_prior$mu + 4 * mu_prior$sigma,
      max(y) + 1
    )
    mu_grid <- seq(mu_lo, mu_hi, length.out = 180)

    var_lo <- max(
      1e-4,
      inverse_gamma_quantile(
        0.005,
        variance_prior$alpha,
        variance_prior$beta
      )
    )
    var_hi <- max(
      inverse_gamma_quantile(
        0.995,
        variance_prior$alpha,
        variance_prior$beta
      ),
      3 * stats::var(c(y, mean(y) + 0.1)),
      0.5
    )
    variance_grid <- exp(
      seq(log(var_lo), log(var_hi), length.out = 160)
    )

    log_prior_mu <- dnorm(
      mu_grid,
      mean = mu_prior$mu,
      sd = mu_prior$sigma,
      log = TRUE
    )
    log_prior_variance <-
      variance_prior$alpha * log(variance_prior$beta) -
      lgamma(variance_prior$alpha) -
      (variance_prior$alpha + 1) * log(variance_grid) -
      variance_prior$beta / variance_grid

    sse <- vapply(
      mu_grid,
      function(mu) sum((y - mu)^2),
      numeric(1)
    )

    log_likelihood <-
      -0.5 * outer(sse, 1 / variance_grid) -
      matrix(
        length(y) / 2 * log(2 * pi * variance_grid),
        nrow = length(mu_grid),
        ncol = length(variance_grid),
        byrow = TRUE
      )

    log_posterior <-
      outer(log_prior_mu, rep(1, length(variance_grid))) +
      outer(rep(1, length(mu_grid)), log_prior_variance) +
      log_likelihood

    posterior_joint <- exp(log_posterior - max(log_posterior))

    mu_weights <- trapezoid_weights(mu_grid)
    variance_weights <- trapezoid_weights(variance_grid)

    posterior_mu <- as.vector(
      posterior_joint %*% variance_weights
    )
    posterior_mu <- posterior_mu /
      sum(posterior_mu * mu_weights)

    posterior_variance <- as.vector(
      crossprod(mu_weights, posterior_joint)
    )
    posterior_variance <- posterior_variance /
      sum(posterior_variance * variance_weights)

    list(
      y = y,
      mu_grid = mu_grid,
      variance_grid = variance_grid,
      prior_mu = dnorm(
        mu_grid,
        mean = mu_prior$mu,
        sd = mu_prior$sigma
      ),
      posterior_mu = posterior_mu,
      prior_variance = inverse_gamma_density(
        variance_grid,
        variance_prior$alpha,
        variance_prior$beta
      ),
      posterior_variance = posterior_variance
    )
  })

  output$data_summary <- renderText({
    y <- observations[seq_len(input$n_obs)]

    sprintf(
      "n = %d · mean = %.2f · sd = %.2f",
      length(y),
      mean(y),
      if (length(y) > 1) sd(y) else 0
    )
  })

  output$mu_plot <- renderPlot({
    post <- posterior()

    plot(
      post$mu_grid,
      post$prior_mu,
      type = "l",
      lwd = 2,
      lty = 2,
      xlab = expression(mu),
      ylab = "Density",
      ylim = c(0, max(post$prior_mu, post$posterior_mu)),
      bty = "n"
    )
    lines(
      post$mu_grid,
      post$posterior_mu,
      lwd = 3
    )
    rug(post$y)
    legend(
      "topright",
      legend = c("Prior", "Posterior"),
      lty = c(2, 1),
      lwd = c(2, 3),
      bty = "n"
    )
  })

  output$variance_plot <- renderPlot({
    post <- posterior()

    plot(
      post$variance_grid,
      post$prior_variance,
      type = "l",
      lwd = 2,
      lty = 2,
      xlab = expression(sigma^2),
      ylab = "Density",
      ylim = c(
        0,
        max(post$prior_variance, post$posterior_variance)
      ),
      bty = "n"
    )
    lines(
      post$variance_grid,
      post$posterior_variance,
      lwd = 3
    )
    legend(
      "topright",
      legend = c("Prior", "Posterior"),
      lty = c(2, 1),
      lwd = c(2, 3),
      bty = "n"
    )
  })
}

shinyApp(ui, server)
