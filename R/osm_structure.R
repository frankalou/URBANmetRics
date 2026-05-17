#' Query and Prepare OSM Features for a Given AOI
#'
#' This function queries OpenStreetMap (OSM) features for a given Area of Interest (AOI)
#' using a set of user-defined OSM tag specifications. It serves as the *core extraction
#' engine* of the URBANmetRics workflow. Wrapper functions such as `building_structure()`,
#' `green_structure()`, and `transport_structure()` rely on this function to retrieve and
#' preprocess OSM data for specific thematic domains.
#'
#' The function:
#' - queries multiple Overpass API fallback servers,
#' - retrieves all matching geometries (points, lines, polygons, multipolygons),
#' - harmonizes attribute columns across geometry types,
#' - repairs invalid geometries,
#' - casts geometry types where necessary (e.g., MULTILINESTRING → LINESTRING),
#' - computes basic metrics (area, length, count),
#' - assigns feature categories based on the provided tag list,
#' - filters results to the AOI.
#'
#' @param aoi An `sf` polygon representing the Area of Interest.
#'   Must be a valid `sf` object.
#' @param tags A named list defining OSM key–value pairs to extract.
#'   Each list element corresponds to an OSM key. Values may be:
#'   - `TRUE` to match all values of that key, or
#'   - a character vector of specific OSM tag values.
#'
#' @return An `sf` object containing all OSM features that match the tag specification
#'   and intersect the AOI. The returned object includes:
#'   \describe{
#'     \item{geometry}{Spatial geometry (POINT, LINESTRING, POLYGON, etc.)}
#'     \item{category}{Assigned category based on the tag list}
#'     \item{area}{Feature area (for polygons)}
#'     \item{length}{Feature length (for lines)}
#'     \item{count}{Feature count (always 1 per row)}
#'     \item{all original OSM attributes}{(e.g., `building`, `landuse`, `highway`, etc.)}
#'   }
#'
#' @details
#' This function is intentionally designed as a *generic OSM extraction framework*.
#' It does not classify features by itself. Instead, wrapper functions provide
#' thematic tag sets and post-processing logic. This modular design ensures:
#' - reproducibility,
#' - extensibility,
#' - consistent preprocessing across all thematic domains.
#'
#' @examples
#' \dontrun{
#' # Example: extract all buildings in an AOI
#' tags <- list(building = TRUE)
#' buildings <- osm_structure(aoi, tags)
#' }
#'
#' @export
osm_structure <- function(aoi, tags){

  # Validate AOI input
  if(!inherits(aoi,"sf")) stop("AOI must be sf")

  # Reproject AOI to Web Mercator for metric calculations
  aoi_proj <- sf::st_transform(aoi, 3857)

  message("Query OSM features (all geometries)...")

  # Build Overpass feature query from tag list
  # - tags is a named list: key = OSM key, value = TRUE or vector of values
  # - TRUE - match all values of that key
  # - vector - match only specific values

  features <- c()
  for(k in names(tags)){
    vals <- tags[[k]]
    if(isTRUE(vals)){
      features <- c(features, paste0('"', k, '"~".*"'))
    } else {
      for(v in vals){
        features <- c(features, paste0('"', k, '"="', v, '"'))
      }
    }
  }

  # Overpass fallback server list
  # - The function tries each server until one succeeds

  servers <- c(
    "https://overpass-api.de/api/interpreter",            # German
    "https://overpass.kumi.systems/api/interpreter",      # Switzerland
    "https://overpass.openstreetmap.fr/api/interpreter"   # France
  )

  osm <- NULL

  for (srv in servers) {
    message(paste("Trying Overpass server:", srv))

    osmdata::set_overpass_url(srv)

    # Build query
    q <- osmdata::opq(sf::st_bbox(aoi)) |>
         osmdata::add_osm_features(features = features)

    # Try request
    osm <- tryCatch(osmdata::osmdata_sf(q), error = function(e) NULL)

    if (!is.null(osm)) {
      message(paste("Success with server:", srv))
      break
    } else {
      message(paste("Server failed:", srv))
    }
  }

  if (is.null(osm)) {
    warning("All Overpass servers failed — please try again later.")
    return(NULL)
  }

  # Collect all geometry types returned by OSM
  all_features <- list(
    polygons = osm$osm_polygons,
    multipolygons = osm$osm_multipolygons,
    lines = osm$osm_lines,
    points = osm$osm_points
  )

  # Remove empty geometry groups
  all_features <- all_features[!sapply(all_features, is.null)]
  all_features <- all_features[sapply(all_features, nrow) > 0]

  if(length(all_features) == 0){
    warning("No features found")
    return(NULL)
  }

  # Harmonize attribute columns across geometry types
  all_cols <- unique(unlist(lapply(all_features, names)))

  prepared <- lapply(all_features, function(x){

    if(is.null(x) || nrow(x) == 0) return(NULL)

    # Add missing columns so all geometry types share the same schema
    missing_cols <- setdiff(all_cols, names(x))
    for(col in missing_cols){
      x[[col]] <- NA
    }

    # Repair invalid geometries
    x <- sf::st_make_valid(x)

    return(x)
  })

  prepared <- prepared[!sapply(prepared, is.null)]

  # Merge all geometry types into a single sf object
  combined <- do.call(dplyr::bind_rows, prepared)
  combined <- sf::st_make_valid(combined)
  combined <- sf::st_transform(combined, 3857)
  combined <- sf::st_filter(combined, aoi_proj)

  # Clip geometries to AOI
  combined <- suppressWarnings(sf::st_intersection(combined, aoi_proj))

  if(nrow(combined) == 0){
    warning("No intersection with AOI")
    return(NULL)
  }

  # Remove empty geometries
  combined <- combined[!sf::st_is_empty(combined), ]

  # Cast Multistring -> Linestring where needed
  ml_idx <- combined$geom_type == "MULTILINESTRING"
  if (any(ml_idx)) {
    combined[ml_idx, ] <- sf::st_cast(combined[ml_idx, ], "LINESTRING")
  }

  # Update geometry type column
  combined$geom_type <- as.character(sf::st_geometry_type(combined))

  # Compute metrics: area, length, count
  combined$area <- NA
  combined$length <- NA
  combined$count <- 1

  poly_idx <- combined$geom_type %in% c("POLYGON","MULTIPOLYGON")
  combined$area[poly_idx] <- as.numeric(sf::st_area(combined[poly_idx, ]))

  line_idx <- combined$geom_type %in% c("LINESTRING")
  combined$length[line_idx] <- as.numeric(sf::st_length(combined[line_idx, ]))

  # Assign category based on tag list
  combined$category <- NA

  for(k in names(tags)){
    if(!k %in% names(combined)) next

    vals <- tags[[k]]

    if(isTRUE(vals)){
      combined$category[!is.na(combined[[k]])] <- k
    } else {
      combined$category[combined[[k]] %in% vals] <- k
    }
  }

  combined <- combined[!is.na(combined$category),]

  if(nrow(combined) == 0){
    warning("No matching features after filtering")
    return(NULL)
  }

  combined
}
