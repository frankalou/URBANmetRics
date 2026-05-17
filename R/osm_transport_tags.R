#' Predefined OSM transport tags
#'
#' A named list of OSM key–value pairs used by `transport_structure()` to
#' extract transport-related features from OpenStreetMap. This list is part of
#' the public API of the URBANmetRics package and can be reused or extended by
#' users to define custom transport tag sets.
#'
#' The list contains three OSM keys commonly associated with transport
#' infrastructure, including roads, railways, and public transport elements:
#'
#' \describe{
#'   \item{highway}{Logical TRUE, meaning all `highway=*` values are matched.}
#'   \item{railway}{Logical TRUE, meaning all `railway=*` values are matched.}
#'   \item{public_transport}{Logical TRUE, meaning all `public_transport=*` values are matched.}
#' }
#'
#' @format A named list of three logical TRUE entries.
#'
#' @examples
#' transport_tags
#'
#' @export
transport_tags <- list(
  highway = TRUE,
  railway = TRUE,
  public_transport = TRUE
)


#' Classify transport features into functional categories
#'
#' Internal helper function used by `transport_structure()` to assign
#' transport classes based on OSM `highway=*`, `railway=*`, and
#' `public_transport=*` tags.
#'
#' @param df An `sf` object returned by `osm_structure()`.
#'
#' @return The same `sf` object with an additional `transport_class` column.
#'
#' @keywords internal
classify_transport <- function(df) {

  if (!"highway" %in% names(df)) df$highway <- NA_character_
  if (!"railway" %in% names(df)) df$railway <- NA_character_
  if (!"public_transport" %in% names(df)) df$public_transport <- NA_character_


  df %>%
    dplyr::mutate(
      highway = as.character(highway),
      railway = as.character(railway),
      public_transport = as.character(public_transport),

      transport_class = dplyr::case_when(
        highway %in% c("motorway", "trunk","primary") ~ "primary_road",
        highway %in% c("secondary", "tertiary", "unclassified") ~"secondary_road",
        highway %in% c("residential", "living_street") ~ "residential_road",
        highway %in% c("pedestrian", "track","footway", "steps","path") ~ "footway",
        highway %in% c("cycleway") ~ "cycleway",
        railway %in% c("rail", "light_rail") ~"rail",
        railway %in% c("subway") ~ "subway",
        railway %in% c("tram") ~ "tram",
        public_transport %in% c("platform", "stop_position", "station") ~ "public_transport",
        TRUE ~ "other"

      )
    )
  }