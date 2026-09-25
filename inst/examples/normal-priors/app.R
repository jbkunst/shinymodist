library(shiny)
library(shinymodist)

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop("Install bslib to run this example.")
}

observations <- mtcars$mpg

prior_color <- "#67AEBB"
posterior_color <- "#0E7490"
data_color <- "#D9A441"

theme <- bslib::bs_theme(
  version = 5,
  primary = posterior_color
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
  title = "Bayesian normal model · mtcars MPG",
  theme = theme,
  sidebar = bslib::sidebar(
    width = 360,
    h5("Prior for mean MPG"),
    modist_input(
      "mu_prior",
      family = "normal",
      value = list(mu = 20, sigma = 5),
      domain = c(5, 35)
    ),
    hr(),
    h5("Prior for MPG variance"),
    modist_input(
      "variance_prior",
      family = "inversegamma",
      value = list(alpha = 5, beta = 120),
      domain = c(0, 100)
    ),
    hr(),
    div(
      style = "max-width: 220px;",
      sliderInput(
        "n_obs",
        "Cars observed",
        min = 2,
        max = length(observations),
        value = 6,
        step = 1,
        ticks = FALSE,
        width = "100%"
      )
    ),
    textOutput("data_summary"),
    tags$small(class = "text-body-secondary", "Data: mtcars$mpg")
  ),
  bslib::card(
    fill = FALSE,
    bslib::card_header("Mean MPG: prior → posterior"),
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
      3 * stats::var(y),
      1
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
      "n = %d · mean = %.1f MPG · sd = %.1f",
      length(y),
      mean(y),
      sd(y)
    )
  })

  output$mu_plot <- renderPlot({
    post <- posterior()
    y_max <- max(post$prior_mu, post$posterior_mu)

    plot(
      post$mu_grid,
      post$prior_mu,
      type = "n",
      xlab = expression(mu),
      ylab = "Density",
      ylim = c(0, y_max * 1.05),
      bty = "n"
    )

    polygon(
      c(post$mu_grid[[1]], post$mu_grid, post$mu_grid[[length(post$mu_grid)]]),
      c(0, post$prior_mu, 0),
      border = NA,
      col = grDevices::adjustcolor(prior_color, alpha.f = 0.16)
    )
    polygon(
      c(post$mu_grid[[1]], post$mu_grid, post$mu_grid[[length(post$mu_grid)]]),
      c(0, post$posterior_mu, 0),
      border = NA,
      col = grDevices::adjustcolor(posterior_color, alpha.f = 0.20)
    )

    lines(
      post$mu_grid,
      post$prior_mu,
      col = prior_color,
      lwd = 2,
      lty = 2
    )
    lines(
      post$mu_grid,
      post$posterior_mu,
      col = posterior_color,
      lwd = 3
    )
    abline(
      v = mean(post$y),
      col = data_color,
      lty = 3,
      lwd = 2
    )
    rug(post$y, col = data_color)

    legend(
      "topright",
      legend = c("Prior", "Posterior", "Sample mean"),
      col = c(prior_color, posterior_color, data_color),
      lty = c(2, 1, 3),
      lwd = c(2, 3, 2),
      bty = "n"
    )
  })

  output$variance_plot <- renderPlot({
    post <- posterior()
    y_max <- max(post$prior_variance, post$posterior_variance)

    plot(
      post$variance_grid,
      post$prior_variance,
      type = "n",
      xlab = expression(sigma^2),
      ylab = "Density",
      ylim = c(0, y_max * 1.05),
      bty = "n"
    )

    polygon(
      c(
        post$variance_grid[[1]],
        post$variance_grid,
        post$variance_grid[[length(post$variance_grid)]]
      ),
      c(0, post$prior_variance, 0),
      border = NA,
      col = grDevices::adjustcolor(prior_color, alpha.f = 0.16)
    )
    polygon(
      c(
        post$variance_grid[[1]],
        post$variance_grid,
        post$variance_grid[[length(post$variance_grid)]]
      ),
      c(0, post$posterior_variance, 0),
      border = NA,
      col = grDevices::adjustcolor(posterior_color, alpha.f = 0.20)
    )

    lines(
      post$variance_grid,
      post$prior_variance,
      col = prior_color,
      lwd = 2,
      lty = 2
    )
    lines(
      post$variance_grid,
      post$posterior_variance,
      col = posterior_color,
      lwd = 3
    )
    abline(
      v = stats::var(post$y),
      col = data_color,
      lty = 3,
      lwd = 2
    )

    legend(
      "topright",
      legend = c("Prior", "Posterior", "Sample variance"),
      col = c(prior_color, posterior_color, data_color),
      lty = c(2, 1, 3),
      lwd = c(2, 3, 2),
      bty = "n"
    )
  })
}

shinyApp(ui, server)
