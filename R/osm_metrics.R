#' Compute Basic OSM Metrics for an AOI
#'
#' This function calculates core geometric and density-based metrics for
#' OSM features extracted with `osm_structure()`. It represents the
#' metrics-level foundation of the URBANmetRics workflow. Wrapper functions
#' such as `building_metrics()`, `green_metrics()`, and `transport_metrics()`
#' build on this function to compute domain-specific indicators.
#'
#' The function:
#' - projects the AOI and OSM features to a metric CRS (EPSG:3857),
#' - computes feature-level area, length, and count,
#' - aggregates metrics by category,
#' - calculates category shares (relative and AOI-based),
#' - computes density metrics per km²
#'
#' @param osm_raw An `sf` object returned by `osm_structure()`, containing
#'   OSM features with a `category` column.
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#'
#' @return A data frame containing aggregated OSM metrics per category,
#'   including:
#'   \describe{
#'     \item{category}{Feature category assigned by the structure wrapper}
#'     \item{Area_m2}{Total area of polygonal features}
#'     \item{Length_m}{Total length of linear features}
#'     \item{Count}{Total feature count}
#'     \item{Area_Share_percent}{Share of total area across categories}
#'     \item{Length_Share_percent}{Share of total length across categories}
#'     \item{Count_Share_percent}{Share of total count across categories}
#'     \item{Area_Share_AOI_percent}{Area share relative to AOI size}
#'     \item{Length_Share_AOI_percent}{Length share relative to AOI size}
#'     \item{Count_Share_AOI_percent}{Count share relative to total count}
#'     \item{Density_m2_per_km2}{Area density per km²}
#'     \item{Density_count_per_km2}{Count density per km²}
#'   }
#'
#' @details
#' This function is the core metrics engine of the URBANmetRics workflow.
#' It does not apply thematic interpretation. Instead, it provides a
#' standardized, geometry-based metrics table that is used by the
#' domain-specific metrics wrappers.
#'
#' The modular design ensures:
#' - consistent metric definitions across domains,
#' - reproducibility,
#' - separation of concerns between extraction, structure, and metrics.
#'
#' @examples
#' \dontrun{
#' raw <- osm_structure(aoi, tags = building_tags)
#' metrics <- osm_metrics(raw, aoi)
#' }
#'
#' @export
osm_metrics <- function(osm_raw, aoi) {

  # Validate inputs
  stopifnot(inherits(aoi, "sf"))
  stopifnot("category" %in% names(osm_raw))

  # Project AOI to metric CRS (Web Mercator)
  aoi_proj <- sf::st_transform(aoi, 3857)
  aoi_area <- as.numeric(sum(sf::st_area(aoi_proj)))
  aoi_km2  <- aoi_area / 1e6

  # Project OSM features to metric CRS
  osm_proj <- sf::st_transform(osm_raw, 3857)

  # Compute feature-level area, length, and count
  osm_proj <- osm_proj %>%
    dplyr::mutate(
      geom_type = sf::st_geometry_type(geometry, by_geometry = TRUE),
      area = dplyr::if_else(
        geom_type %in% c("POLYGON", "MULTIPOLYGON"),
        as.numeric(sf::st_area(.)),
        0
      ),
      length = dplyr::if_else(
        geom_type %in% c("LINESTRING", "MULTILINESTRING"),
        as.numeric(sf::st_length(.)),
        0
      ),
      count = 1
    )

  # Aggregate metrics by category
  category_totals <- osm_proj %>%
    sf::st_drop_geometry() %>%
    dplyr::group_by(category) %>%
    dplyr::summarise(
      Area_m2   = sum(area),
      Length_m  = sum(length),
      Count     = sum(count),
      .groups = "drop"
    )

  # Compute totals across all categories
  total_area   <- sum(category_totals$Area_m2)
  total_length <- sum(category_totals$Length_m)
  total_count  <- sum(category_totals$Count)

  # Final metrics table
  result <- category_totals %>%
    dplyr::mutate(
      Area_Share_percent   = Area_m2  / total_area   * 100,
      Length_Share_percent = Length_m / total_length * 100,
      Count_Share_percent  = Count    / total_count  * 100,

      Area_Share_AOI_percent   = Area_m2  / aoi_area * 100,
      Length_Share_AOI_percent = Length_m / aoi_area * 100,
      Count_Share_AOI_percent  = Count    / total_count * 100,

      Density_m2_per_km2    = Area_m2 / aoi_km2,
      Density_count_per_km2 = Count   / aoi_km2
    )

  return(result)
}
