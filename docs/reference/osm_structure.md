# Query and Prepare OSM Features for a Given AOI

This function queries OpenStreetMap (OSM) features for a given Area of
Interest (AOI) using a set of user-defined OSM tag specifications. It
serves as the *core extraction engine* of the URBANmetRics workflow.
Wrapper functions such as
[`building_structure()`](building_structure.md),
[`green_structure()`](green_structure.md), and
[`transport_structure()`](transport_structure.md) rely on this function
to retrieve and preprocess OSM data for specific thematic domains.

## Usage

``` r
osm_structure(aoi, tags)
```

## Arguments

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

- tags:

  A named list defining OSM key–value pairs to extract. Each list
  element corresponds to an OSM key. Values may be:

  - `TRUE` to match all values of that key, or

  - a character vector of specific OSM tag values.

## Value

An `sf` object containing all OSM features that match the tag
specification and intersect the AOI. The returned object includes:

- geometry:

  Spatial geometry (POINT, LINESTRING, POLYGON, etc.)

- category:

  Assigned category based on the tag list

- area:

  Feature area (for polygons)

- length:

  Feature length (for lines)

- count:

  Feature count (always 1 per row)

- all original OSM attributes:

  (e.g., `building`, `landuse`, `highway`, etc.)

## Details

The function:

- queries multiple Overpass API fallback servers,

- retrieves all matching geometries (points, lines, polygons,
  multipolygons),

- harmonizes attribute columns across geometry types,

- repairs invalid geometries,

- casts geometry types where necessary (e.g., MULTILINESTRING →
  LINESTRING),

- computes basic metrics (area, length, count),

- assigns feature categories based on the provided tag list,

- filters results to the AOI.

This function is intentionally designed as a *generic OSM extraction
framework*. It does not classify features by itself. Instead, wrapper
functions provide thematic tag sets and post-processing logic. This
modular design ensures:

- reproducibility,

- extensibility,

- consistent preprocessing across all thematic domains.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example: extract all buildings in an AOI
tags <- list(building = TRUE)
buildings <- osm_structure(aoi, tags)
} # }
```
