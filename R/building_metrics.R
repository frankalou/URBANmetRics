#' Compute Building Metrics for an AOI
#'
#' This function is a wrapper around `osm_metrics()` and processes the output
#' of `building_structure()`. It calculates geometry-based building metrics
#' per category and provides a structured summary for downstream analysis
#' within the URBANmetRics workflow.
#'
#' The function:
#' - projects the AOI and building features to a metric CRS (EPSG:3857),
#' - computes category-level metrics using `osm_metrics()`,
#' - calculates total building area and its share of the AOI,
#' - returns a structured list containing AOI information, summary statistics,
#'   and category-level metrics.
#'
#' @param building_result An `sf` object returned by `building_structure()`,
#'   containing building features with a `category` column.
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return A named list containing:
#'   \describe{
#'     \item{AOI}{AOI area in m² and km²}
#'     \item{summary}{Total building area and its share of the AOI}
#'     \item{categories}{A data frame of building metrics per category
#'       returned by `osm_metrics()`}
#'   }
#'
#' @details
#' This function provides the building-specific metrics layer of the
#' URBANmetRics workflow. It does not classify buildings (this is handled in
#' `building_structure()`), but instead computes geometric and density-based
#' metrics for each building category.
#'
#' The modular design ensures:
#' - consistent metric definitions across domains,
#' - reproducibility,
#' - separation of concerns between structure extraction and metric computation.
#'
#' @examples
#' \dontrun{
#' buildings <- building_structure(aoi)
#' metrics <- building_metrics(buildings, aoi)
#' metrics$summary
#' }
#'
#' @export
building_metrics <- function(building_result, aoi) {

  # Validate inputs
  stopifnot(inherits(aoi, "sf"))
  stopifnot("category" %in% names(building_result))

  # Project AOI and building features to metric CRS (Web Mercator)
  aoi_proj <- sf::st_transform(aoi, 3857)
  building_proj <- sf::st_transform(building_result, 3857)

  # Compute category-level metrics using the core metrics engine
  metrics <- osm_metrics(building_proj, aoi_proj)

  # Total building area across all categories
  total_area <- sum(metrics$Area_m2)

  # AOI area in m²
  aoi_area <- as.numeric(sum(sf::st_area(aoi_proj)))

  # Return structured output
  return(list(
    AOI = list(
      area_m2 = aoi_area,
      area_km2 = aoi_area / 1e6
    ),
    summary = list(
      category = "building",
      total_area_m2 = total_area,
      total_area_km2 = total_area / 1e6,
      share_of_AOI = total_area / aoi_area
    ),
    categories = metrics
  ))
}
