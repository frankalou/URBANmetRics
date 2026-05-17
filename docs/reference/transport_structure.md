# Extract Transport Features for an AOI Using Predefined OSM Tags

This function is a wrapper around [`osm_structure()`](osm_structure.md)
and provides a predefined set of OSM transport-related tags
(`transport_tags`). It represents the transport-specific entry point of
the URBANmetRics workflow. The function retrieves all OSM transport
features within the Area of Interest (AOI), harmonizes them through the
core extraction engine, and applies a transport classification routine.

## Usage

``` r
transport_structure(aoi)
```

## Arguments

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

An `sf` object containing transport features intersecting the AOI,
including:

- geometry:

  Spatial geometry of each transport feature

- transport_class:

  Assigned transport class from
  [`classify_transport()`](classify_transport.md)

- category:

  Alias for `transport_class`, used for consistency

- area:

  Feature area (if polygonal)

- length:

  Feature length (for linear features)

- count:

  Feature count (always 1 per row)

- all original OSM attributes:

  All OSM key–value pairs returned by Overpass

## Details

The function:

- calls [`osm_structure()`](osm_structure.md) with the predefined
  `transport_tags`,

- validates and filters the returned OSM features,

- applies [`classify_transport()`](classify_transport.md) to assign
  transport classes,

- returns a clean `sf` object with transport categories and metrics.

This function is not intended to be used as a standalone OSM extractor.
Instead, it provides a standardized transport-specific wrapper around
[`osm_structure()`](osm_structure.md). The modular design ensures:

- consistent preprocessing across thematic domains,

- reproducible transport classification,

- separation of concerns between extraction and interpretation

## Examples

``` r
if (FALSE) { # \dontrun{
transport <- transport_structure(aoi)
plot(transport["transport_class"])
} # }
```
