#' Compute Transport Metrics for an AOI
#'
#' This function is a wrapper around `osm_metrics()` and processes the output
#' of `transport_structure()`. It calculates geometry-based transport metrics
#' per category and provides a structured summary for downstream analysis
#' within the URBANmetRics workflow.
#'
#' The function:
#' - projects the AOI and transport features to a metric CRS (EPSG:3857),
#' - computes category-level metrics using `osm_metrics()`,
#' - calculates total transport area, length, and feature count,
#' - returns a structured list containing AOI information, summary statistics,
#'   and category-level metrics.
#'
#' @param transport_result An `sf` object returned by `transport_structure()`,
#'   containing transport features with a `category` column.
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return A named list containing:
#'   \describe{
#'     \item{AOI}{AOI area in m² and km²}
#'     \item{summary}{Total transport area, length, count, and AOI shares}
#'     \item{categories}{A data frame of transport metrics per category
#'       returned by `osm_metrics()`}
#'   }
#'
#' @details
#' This function provides the transport-specific metrics layer of the
#' URBANmetRics workflow. It does not classify transport features (this is
#' handled in `transport_structure()`), but instead computes geometric and
#' density-based metrics for each transport category.
#'
#' Transport metrics differ from building and green metrics because linear
#' features (e.g., roads, railways, cycleways) play a dominant role. Therefore,
#' the summary includes total length and length-based density indicators.
#'
#' The modular design ensures:
#' - consistent metric definitions across domains,
#' - reproducibility,
#' - separation of concerns between structure extraction and metric computation.
#'
#' @examples
#' \dontrun{
#' transport <- transport_structure(aoi)
#' metrics <- transport_metrics(transport, aoi)
#' metrics$summary
#' }
#'
#' @export
transport_metrics <- function(transport_result, aoi) {

  # Validate inputs
  stopifnot(inherits(aoi, "sf"))
  stopifnot("category" %in% names(transport_result))

  # Project AOI to metric CRS (Web Mercator)
  aoi_proj <- sf::st_transform(aoi, 3857)
  aoi_area <- as.numeric(sum(sf::st_area(aoi_proj)))

  # Project transport features to metric CRS
  transport_proj <- sf::st_transform(transport_result, 3857)

  # Compute category-level metrics using the core metrics engine
  metrics <- osm_metrics(transport_proj, aoi_proj)

  # Aggregate totals across all categories
  total_area   <- sum(metrics$Area_m2)
  total_length <- sum(metrics$Length_m)
  total_count  <- sum(metrics$Count)

  # Return structured output
  return(list(
    AOI = list(
      area_m2  = aoi_area,
      area_km2 = aoi_area / 1e6
    ),
    summary = list(
      category           = "transport",
      total_area_m2      = total_area,
      total_area_km2     = total_area / 1e6,
      total_length_m     = total_length,
      total_length_km    = total_length / 1000,
      total_count        = total_count,
      share_of_AOI_area  = total_area / aoi_area,
      density_km_per_km2 = (total_length / 1000) / (aoi_area / 1e6)
    ),
    categories = metrics
  ))
}