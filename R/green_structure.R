#' Extract Green Space Features for an AOI Using Predefined OSM Tags
#'
#' This function is a wrapper around `osm_structure()` and provides a
#' predefined set of OSM green-space tags (`green_tags`). It represents the
#' green-specific entry point of the URBANmetRics workflow. The function
#' retrieves all OSM green features within the Area of Interest (AOI),
#' harmonizes them through the core extraction engine, and prepares them
#' for downstream metric calculations.
#'
#' The function:
#' - calls `osm_structure()` with the predefined `green_tags`,
#' - validates and filters the returned OSM features,
#' - returns a clean `sf` object with green-space categories and metrics.
#'
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return An `sf` object containing green-space features intersecting the AOI,
#'   including:
#'   \describe{
#'     \item{geometry}{Spatial geometry of each green feature}
#'     \item{category}{Assigned green-space category based on `green_tags`}
#'     \item{area}{Feature area (for polygons)}
#'     \item{length}{Feature length (for linear features)}
#'     \item{count}{Feature count (always 1 per row)}
#'     \item{all original OSM attributes}{All OSM key–value pairs returned by Overpass}
#'   }
#'
#' @details
#' This function is not intended to be used as a standalone OSM extractor.
#' Instead, it provides a standardized green-specific wrapper around
#' `osm_structure()`. The modular design ensures:
#' - consistent preprocessing across thematic domains,
#' - reproducible green-space classification,
#' - separation of concerns between extraction and interpretation.
#'
#' @examples
#' \dontrun{
#' greens <- green_structure(aoi)
#' plot(greens["category"])
#' }
#'
#' @export
green_structure <- function(aoi){

  # Call the core OSM extraction engine with predefined green-space tags.
  # `green_tags` is a standardized tag set defined in the package.
  raw <- osm_structure(aoi, tags = green_tags)

  # Handle cases where no features were returned.
  if (is.null(raw) || !inherits(raw, "sf") || nrow(raw) == 0) {
    warning("No green features found in AOI")
    return(NULL)
  }

  return(raw)
}
