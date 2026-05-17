##' Compute Green Space Metrics for an AOI
#'
#' This function is a wrapper around `osm_metrics()` and processes the output
#' of `green_structure()`. It calculates geometry-based green-space metrics
#' per category and provides a structured summary for downstream analysis
#' within the URBANmetRics workflow.
#'
#' The function:
#' - projects the AOI and green features to a metric CRS (EPSG:3857),
#' - computes category-level metrics using `osm_metrics()`,
#' - calculates total green area and its share of the AOI,
#' - returns a structured list containing AOI information, summary statistics,
#'   and category-level metrics.
#'
#' @param green_result An `sf` object returned by `green_structure()`,
#'   containing green-space features with a `category` column.
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return A named list containing:
#'   \describe{
#'     \item{AOI}{AOI area in m² and km²}
#'     \item{summary}{Total green area and its share of the AOI}
#'     \item{categories}{A data frame of green-space metrics per category
#'       returned by `osm_metrics()`}
#'   }
#'
#' @details
#' This function provides the green-specific metrics layer of the
#' URBANmetRics workflow. It does not classify green features (this is handled
#' in `green_structure()`), but instead computes geometric and density-based
#' metrics for each green-space category.
#'
#' The modular design ensures:
#' - consistent metric definitions across domains,
#' - reproducibility,
#' - separation of concerns between structure extraction and metric computation
#'
#' @examples
#' \dontrun{
#' greens <- green_structure(aoi)
#' metrics <- green_metrics(greens, aoi)
#' metrics$summary
#' }
#'
#' @export
green_metrics <- function(green_result, aoi) {

  # Validate inputs
  stopifnot(inherits(aoi, "sf"))
  stopifnot("category" %in% names(green_result))

  # Project AOI and green features to metric CRS (Web Mercator)
  aoi_proj <- sf::st_transform(aoi, 3857)
  green_proj <- sf::st_transform(green_result, 3857)

  # Compute category-level metrics using the core metrics engine
  metrics <- osm_metrics(green_proj, aoi_proj)

  # Total green area across all categories
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
      category = "green",
      total_area_m2 = total_area,
      total_area_km2 = total_area / 1e6,
      share_of_AOI = total_area / aoi_area
    ),
    categories = metrics
  ))
}