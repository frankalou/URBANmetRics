# Extract Building Features for an AOI Using Predefined OSM Tags

This function is a wrapper around [`osm_structure()`](osm_structure.md)
and provides a predefined set of OSM building tags (`building_tags`). It
represents the building-specific entry point of the URBANmetRics
workflow. The function retrieves all OSM building features within the
Area of Interest (AOI), harmonizes them through the core extraction
engine, and applies a building classification routine.

## Usage

``` r
building_structure(aoi)
```

## Arguments

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

An `sf` object containing building features intersecting the AOI,
including:

- geometry:

  Spatial geometry of each building feature

- building_class:

  Assigned building class from
  [`classify_buildings()`](classify_buildings.md)

- category:

  Alias for `building_class`, used for consistency

- area:

  Feature area (if polygonal)

- length:

  Feature length (if linear)

- count:

  Feature count (always 1 per row)

- all original OSM attributes:

  All OSM key–value pairs returned by Overpass

## Details

The function:

- calls [`osm_structure()`](osm_structure.md) with the predefined
  `building_tags`,

- filters and validates the returned OSM features,

- applies [`classify_buildings()`](classify_buildings.md) to assign
  building classes,

- returns a clean `sf` object with building categories and metrics.

This function is not intended to be used as a standalone OSM extractor.
Instead, it provides a standardized building-specific wrapper around
[`osm_structure()`](osm_structure.md). The modular design ensures:

- consistent preprocessing across thematic domains,

- reproducible building classification,

- separation of concerns between extraction and interpretation.

## Examples

``` r
if (FALSE) { # \dontrun{
buildings <- building_structure(aoi)
plot(buildings["building_class"])
} # }
```
