% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dppi_strategy.R
\name{dppi}
\alias{dppi}
\title{Dynamic Proportion Portfolio Insurance (DPPI)}
\usage{
dppi(q, tdate, f, tper = 0.1, rper = 0.2, tcost = 0, int = TRUE)
}
\arguments{
\item{q}{numeric value for quantity to be hedged, either positive (net buyer) or negative (net seller)}

\item{tdate}{date vector with trading days}

\item{f}{numeric futures price vector}

\item{tper}{numeric target price markup/down to the price on the first trading day}

\item{rper}{numeric risk factor as a percentage of the price on the first trading day}

\item{tcost}{numeric transaction costs pr unit}

\item{int}{TRUE/FALSE integer restriction on tradable volume}
}
\value{
instance of the DPPI class
}
\description{
Implements DPPI strategy for commodity price risk management
}

