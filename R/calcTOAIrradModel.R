#' Compute extraterrestrial solar irradiance (ESun) based on RSR
#'
#' @description
#' Compute mean extraterrestrial solar irradiance (ESun) using tabulated mean
#' solar spectral data and the band specifiv relative spectral response 
#' functions (rsr).
#' 
#' @param rsr relative spectral response function (see details for structure)
#' @param model tabulated solar radiation model to be used 
#' @param normalize normalize ESun to mean earth sun distance
#' @param date date of the sensor overpath (YYYY-MM-DD or POSIX* object) (
#' only required if ESun should be corrected to the actual earth sun distance)
#'
#' @return Vector object containing ESun for each band
#'
#' @export calcTOAIrradModel
#' 
#' @details Computation of ESun is taken from Updike and Comp (2011).
#' 
#' Tabulated values for mean earth sun distance are taken from the 
#' data sources mentionend in the references. 
#' 
#' If results should not be normalized to a mean earth sun distance, the 
#' actual earth sun distance is approximated by the day of the year using
#' \code{\link{calcEartSunDist}}.
#' 
#' Relative spectral response values have to be supplied as a as a data frame
#' which has at least these three columns: (i) a column "Band" for the sensor
#' band number (i.e. 1, 2, etc.), (ii) a column "WAVELENGTH" for the WAVELENGTH 
#' data in full nm steps, and (iii) a column "RSR" for the 
#' response information [0...1].
#' 
#' @references 
#' Updike T, Comp C (2011) Radiometric use of WorldView-2 imagery. 
#' Technical Note, URL 
#' \url{https://www.digitalglobe.com/sites/default/files/Radiometric_Use_of_WorldView-2_Imagery(1).pdf}.
#' 
#' Tabulated relative spectral response functions (nm-1) are taken from taken from the
#' \href{http://landsat.usgs.gov/instructions.php}{spectral viewer}
#' of the USGS Landsat FAQ.
#' 
#' Tabulated solar irradiance (W m-2 nm-1) is taken from taken from the 
#' \href{http://rredc.nrel.gov/solar/spectra/am0/modtran.html}{National Renewable 
#' Energy Laboratory}.
#' 
#' @seealso \code{\link{calcTOAIrradRadTable}} for tabulated solar irradiance
#' values from the literature or \code{\link{calcTOAIrradRadRef}} for the 
#' computation of the solar irradiance based on maximum radiation and reflection
#' values of the dataset.
#' 
#' See \code{\link{calcEartSunDist}} for calculating the sun-earth 
#' distance based on the day of the year which is called by this function if
#' ESun should be corrected for actual earth sun distance.
#' 
#' See \code{\link{eSun}} which can be used as a wrapper function for the
#' satellite sensors already included in this package.
#' 
#' @examples
#' lut <- lutInfo()
#' calcTOAIrradModel(lut$L8_RSR, model = "MNewKur")
#' 
calcTOAIrradModel <- function(rsr, model = "MNewKur", 
                               normalize = TRUE, date){
  toa <- lut$SOLAR
  toa$WAVELENGTH <- round(toa$WAVELENGTH, 0)
  toa_aggregated <- aggregate(toa, by = list(toa$WAVELENGTH), FUN = "mean")
  
  rsr <- rsr[, c(grep("BAND", colnames(rsr)), grep("WAVELENGTH", colnames(rsr)), 
                 grep("RSR", colnames(rsr)))]
  
  eSun <- lapply(unique(rsr$BAND), function(x){
    rsr_solar <- merge(rsr[rsr$BAND == x,], toa_aggregated, by = "WAVELENGTH")
    if(nrow(rsr_solar) > 0){
      act_eSun <- aggregate(rsr_solar$RSR * rsr_solar[,grep(model, names(rsr_solar))], 
                            by = list(rsr_solar$BAND), FUN = "sum")[2] /
        aggregate(rsr_solar$RSR, by = list(rsr_solar$BAND), FUN = "sum")[2] * 1000
      act_eSun <- unlist(act_eSun)
    } else {
      act_eSun <- c(NA)
    }
    names(act_eSun) <- paste0("Band_", x)
    return(act_eSun)
  })
  eSun <- unlist(eSun)
  
 if(normalize == FALSE){
    if(missing(date)){
      stop("Variable date is missing.")
    }
    esd <- calcEartSunDist(date)
    eSun <- esd * eSun
  }
  return(eSun)
}