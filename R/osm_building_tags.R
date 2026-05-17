#' Predefined OSM building tags
#'
#' A named list of OSM key–value pairs used by `building_structure()` to
#' extract building features from OpenStreetMap.
#'
#' @format A named list with one element:
#' \describe{
#'   \item{building}{Logical TRUE, meaning all `building=*` values are matched}
#' }
#'
#' @examples
#' building_tags
#'
#' @export
building_tags <- list(building = TRUE)


#' Classify building features into functional categories
#'
#' This internal helper function assigns building classes based on OSM
#' `building=*` and `amenity=*` tags. It is used by `building_structure()`
#' to create the `building_class` and `category` columns.
#'
#' @param df An `sf` object returned by `osm_structure()`.
#'
#' @return The same `sf` object with an additional `building_class` column.
#'
#' @keywords internal
classify_buildings <- function(df) {

  # Ensure missing columns are included
  if (!"building" %in% names(df)) {
    df$building <- NA_character_
  }
  if (!"amenity" %in% names(df)) {
    df$amenity <- NA_character_
  }

  df %>%
    dplyr::mutate(
      building = as.character(building),
      amenity  = as.character(amenity),

      building_class = dplyr::case_when(
        building %in% c("house", "detached", "residential", "apartments") ~ "residential",
        building %in% c("commercial", "office", "retail", "supermarket") ~ "commercial",
        building %in% c("industrial", "warehouse") ~ "industrial",

        building %in% c("religious", "cathedral", "chapel", "church", "mosque", "synagogue",
                        "kindergarten", "college", "school", "university", "museum","civic",
                        "hospital") ~ "public",

        amenity %in% c("hospital", "school", "university", "college", "kindergarten") ~ "public",

        building %in% c("carport", "garage","garages", "parking") ~ "parking",

        is.na(building) ~ "unknown",
        TRUE ~ "other"
      )
    )
}