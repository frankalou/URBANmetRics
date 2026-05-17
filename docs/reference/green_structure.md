# Extract Green Space Features for an AOI Using Predefined OSM Tags

This function is a wrapper around [`osm_structure()`](osm_structure.md)
and provides a predefined set of OSM green-space tags (`green_tags`). It
represents the green-specific entry point of the URBANmetRics workflow.
The function retrieves all OSM green features within the Area of
Interest (AOI), harmonizes them through the core extraction engine, and
prepares them for downstream metric calculations.

## Usage

``` r
green_structure(aoi)
```

## Arguments

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

An `sf` object containing green-space features intersecting the AOI,
including:

- geometry:

  Spatial geometry of each green feature

- category:

  Assigned green-space category based on `green_tags`

- area:

  Feature area (for polygons)

- length:

  Feature length (for linear features)

- count:

  Feature count (always 1 per row)

- all original OSM attributes:

  All OSM key–value pairs returned by Overpass

## Details

The function:

- calls [`osm_structure()`](osm_structure.md) with the predefined
  `green_tags`,

- validates and filters the returned OSM features,

- returns a clean `sf` object with green-space categories and metrics.

This function is not intended to be used as a standalone OSM extractor.
Instead, it provides a standardized green-specific wrapper around
[`osm_structure()`](osm_structure.md). The modular design ensures:

- consistent preprocessing across thematic domains,

- reproducible green-space classification,

- separation of concerns between extraction and interpretation.

## Examples

``` r
if (FALSE) { # \dontrun{
greens <- green_structure(aoi)
plot(greens["category"])
} # }
```
