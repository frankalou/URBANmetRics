#' Calculate green area share
#'
#' @param green_area numeric, area covered by green space
#' @param total_area numeric, total area of AOI
#' @return numeric, share of green area
#' @export
green_share <- function(green_area, total_area) {
  # Sicherheitscheck: keine Division durch 0
  if (total_area == 0) {
    warning("total_area is zero, returning NA")
    return(NA)
  }
  green_area / total_area
}