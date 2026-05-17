#' Predefined OSM green-space tags
#'
#' A named list of OSM key–value pairs used by `green_structure()` to
#' extract green-space features from OpenStreetMap. This list is part of the
#' public API of the URBANmetRics package and can be reused or extended by
#' users to define custom green-space tag sets.
#'
#' The list contains three OSM keys commonly associated with vegetation,
#' parks, natural areas, and other forms of urban green space:
#'
#' \describe{
#'   \item{leisure}{OSM `leisure=*` values representing recreational green areas
#'     such as parks, gardens, allotments, and nature reserves.}
#'   \item{landuse}{OSM `landuse=*` values representing vegetated land uses
#'     such as forest, meadow, orchard, or cemetery.}
#'   \item{natural}{OSM `natural=*` values representing natural vegetation types
#'     such as wood, grassland, scrub, or heath.}
#' }
#'
#' @format A named list of three character vectors.
#'
#' @examples
#' green_tags
#'
#' @export
green_tags <- list(
  leisure = c(
    "park",
    "dog_park",
    "garden",
    "allotments",
    "nature_reserve",
    "recreation_ground"
  ),
  landuse = c(
    "forest",
    "grass",
    "meadow",
    "village_green",
    "orchard",
    "cemetery"
  ),
  natural = c(
    "wood",
    "grassland",
    "scrub",
    "heath"
  )
)