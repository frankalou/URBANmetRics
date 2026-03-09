#' Calculate green space share within an AOI
#'
#' Calculates the proportion of green space within a given area of interest
#' using OpenStreetMap data.
#'
#' @param aoi sf object. Polygon representing the area of interest.
#'
#' @return Numeric. Share of green space within the AOI (0–1).
#' @export

green_share <- function(aoi) {

  if (!inherits(aoi, "sf")) {
    stop("AOI must be an sf object")
  }

  # AOI area
  total_area <- sum(sf::st_area(aoi))

  # OSM greenspaces 
  green <- osmdata::opq(sf::st_bbox(aoi)) |>
    osmdata::add_osm_feature(key = "landuse", value = "grass") |>
    osmdata::osmdata_sf()

  green_polygons <- green$osm_polygons

  # Schnitt mit AOI
  green_intersection <- sf::st_intersection(green_polygons, aoi)

  # Grünfläche berechnen
  green_area <- sum(sf::st_area(green_intersection))

  as.numeric(green_area / total_area)
}