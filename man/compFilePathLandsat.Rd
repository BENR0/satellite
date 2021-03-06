% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/compFilePathLandsat.R
\name{compFilePathLandsat}
\alias{compFilePathLandsat}
\title{Get filename, bands and metadata file for Landsat 7 and 8 standard 1B/T format}
\usage{
compFilePathLandsat(files)
}
\arguments{
\item{files}{Path and filename(s) of one or more Landsat band files or,
alternatively, one or more Landsat metadata files.}
}
\value{
\code{data.frame} containing filepaths, band numbers and metadata
filepaths.
}
\description{
The function compiles the sensor, band, filename and metadata filename information
for standard level 1B/T Landsat files.
}
\examples{
path <- system.file("extdata", package = "satellite")
files <- list.files(path, pattern = glob2rx("LC8*.TIF"), full.names = TRUE)
compFilePathLandsat(files)
}

