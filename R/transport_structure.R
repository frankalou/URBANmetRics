#' Extract Transport Features for an AOI Using Predefined OSM Tags
#'
#' This function is a wrapper around `osm_structure()` and provides a
#' predefined set of OSM transport-related tags (`transport_tags`). It represents
#' the transport-specific entry point of the URBANmetRics workflow. The function
#' retrieves all OSM transport features within the Area of Interest (AOI),
#' harmonizes them through the core extraction engine, and applies a transport
#' classification routine.
#'
#' The function:
#' - calls `osm_structure()` with the predefined `transport_tags`,
#' - validates and filters the returned OSM features,
#' - applies `classify_transport()` to assign transport classes,
#' - returns a clean `sf` object with transport categories and metrics.
#'
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return An `sf` object containing transport features intersecting the AOI,
#'   including:
#'   \describe{
#'     \item{geometry}{Spatial geometry of each transport feature}
#'     \item{transport_class}{Assigned transport class from `classify_transport()`}
#'     \item{category}{Alias for `transport_class`, used for consistency}
#'     \item{area}{Feature area (if polygonal)}
#'     \item{length}{Feature length (for linear features)}
#'     \item{count}{Feature count (always 1 per row)}
#'     \item{all original OSM attributes}{All OSM key–value pairs returned by Overpass}
#'   }
#'
#' @details
#' This function is not intended to be used as a standalone OSM extractor.
#' Instead, it provides a standardized transport-specific wrapper around
#' `osm_structure()`. The modular design ensures:
#' - consistent preprocessing across thematic domains,
#' - reproducible transport classification,
#' - separation of concerns between extraction and interpretation
#'
#' @examples
#' \dontrun{
#' transport <- transport_structure(aoi)
#' plot(transport["transport_class"])
#' }
#'
#' @export
transport_structure <- function(aoi) {

  # Call the core OSM extraction engine with predefined transport tags
  # `transport_tags` is a standardized tag set defined in the package
  raw <- osm_structure(aoi, tags = transport_tags)

  # Cases where no features were returned
  if (is.null(raw) || !inherits(raw, "sf") || nrow(raw) == 0) {
    warning("No transport features found in AOI")
    return(NULL)
  }

  # Classify transport types using the package's classification routine
  classified <- classify_transport(raw)

  # Assign a generic category column for consistency across domains
  classified$category <- classified$transport_class

  return(classified)
}
