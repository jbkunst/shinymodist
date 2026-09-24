test_that("normal input carries initial configuration", {
  x <- modist_input(
    "dist",
    family = "normal",
    value = list(mu = 1, sigma = 2),
    domain = c(-5, 5)
  )

  config <- jsonlite::fromJSON(
    x$attribs[["data-shinymodist-config"]],
    simplifyVector = FALSE
  )

  expect_equal(x$attribs$id, "dist")
  expect_equal(config$family, "normal")
  expect_equal(config$value$mu, 1)
  expect_equal(config$value$sigma, 2)
  expect_equal(unlist(config$domain), c(-5, 5))
})

test_that("all bundled modist families are accepted", {
  families <- c(
    "normal", "beta", "gamma", "studentt", "exponential",
    "halfnormal", "lognormal", "cauchy", "laplace", "logistic",
    "weibull", "halfstudentt", "chisquared", "inversegamma",
    "kumaraswamy"
  )

  for (family in families) {
    expect_silent(modist_input(family, family = family))
  }
})

test_that("invalid domains fail early", {
  expect_error(modist_input("x", domain = c(1, 1)), "strictly increasing")
  expect_error(modist_input("x", domain = c(1, Inf)), "finite")
})

test_that("positive distribution parameters are validated", {
  expect_error(
    modist_input("x", value = list(sigma = 0)),
    "sigma"
  )

  expect_error(
    modist_input("x", family = "beta", value = list(alpha = -1)),
    "alpha"
  )

  expect_error(
    modist_input("x", family = "studentt", value = list(nu = 0)),
    "nu"
  )

  expect_error(
    modist_input("x", family = "cauchy", value = list(beta = 0)),
    "beta"
  )
})
