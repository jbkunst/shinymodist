\name{update_modist_input}
\alias{update_modist_input}
\title{Update an interactive distribution input}
\usage{
update_modist_input(
  input_id,
  value,
  session = shiny::getDefaultReactiveDomain()
)
}
\arguments{
\item{input_id}{Id of the input to update.}
\item{value}{Named list of parameter values to update.}
\item{session}{The Shiny session.}
}
\value{Invisibly returns \code{NULL}.}
\description{
Updates one or more parameter values of an existing \code{modist_input()} from the Shiny server.
}
