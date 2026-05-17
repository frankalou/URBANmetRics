#' Extract Building Features for an AOI Using Predefined OSM Tags
#'
#' This function is a wrapper around `osm_structure()` and provides a
#' predefined set of OSM building tags (`building_tags`). It represents the
#' building-specific entry point of the URBANmetRics workflow. The function
#' retrieves all OSM building features within the Area of Interest (AOI),
#' harmonizes them through the core extraction engine, and applies a
#' building classification routine.
#'
#' The function:
#' - calls `osm_structure()` with the predefined `building_tags`,
#' - filters and validates the returned OSM features,
#' - applies `classify_buildings()` to assign building classes,
#' - returns a clean `sf` object with building categories and metrics.
#'
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return An `sf` object containing building features intersecting the AOI,
#'   including:
#'   \describe{
#'     \item{geometry}{Spatial geometry of each building feature}
#'     \item{building_class}{Assigned building class from `classify_buildings()`}
#'     \item{category}{Alias for `building_class`, used for consistency}
#'     \item{area}{Feature area (if polygonal)}
#'     \item{length}{Feature length (if linear)}
#'     \item{count}{Feature count (always 1 per row)}
#'     \item{all original OSM attributes}{All OSM key–value pairs returned by Overpass}
#'   }
#'
#' @details
#' This function is not intended to be used as a standalone OSM extractor.
#' Instead, it provides a standardized building-specific wrapper around
#' `osm_structure()`. The modular design ensures:
#' - consistent preprocessing across thematic domains,
#' - reproducible building classification,
#' - separation of concerns between extraction and interpretation.
#'
#' @examples
#' \dontrun{
#' buildings <- building_structure(aoi)
#' plot(buildings["building_class"])
#' }
#'
#' @export
building_structure <- function(aoi){

  # Call the core OSM extraction engine with predefined building tags.
  # `building_tags` is a standardized tag set defined in the package.
  raw <- osm_structure(aoi, tags = building_tags)

  # Handle cases where no features were returned.
  if (is.null(raw) || !inherits(raw, "sf") || nrow(raw) == 0) {
    warning("No building features found in AOI")
    return(NULL)
  }

  #Classify building types.
  classified <- classify_buildings(raw)

  # Assign a generic category column for consistency across domains.
  classified$category <- classified$building_class

  return(classified)
}
