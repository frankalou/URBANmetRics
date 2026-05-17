# Compute Building Metrics for an AOI

This function is a wrapper around [`osm_metrics()`](osm_metrics.md) and
processes the output of [`building_structure()`](building_structure.md).
It calculates geometry-based building metrics per category and provides
a structured summary for downstream analysis within the URBANmetRics
workflow.

## Usage

``` r
building_metrics(building_result, aoi)
```

## Arguments

- building_result:

  An `sf` object returned by
  [`building_structure()`](building_structure.md), containing building
  features with a `category` column.

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

A named list containing:

- AOI:

  AOI area in m² and km²

- summary:

  Total building area and its share of the AOI

- categories:

  A data frame of building metrics per category returned by
  [`osm_metrics()`](osm_metrics.md)

## Details

The function:

- projects the AOI and building features to a metric CRS (EPSG:3857),

- computes category-level metrics using
  [`osm_metrics()`](osm_metrics.md),

- calculates total building area and its share of the AOI,

- returns a structured list containing AOI information, summary
  statistics, and category-level metrics.

This function provides the building-specific metrics layer of the
URBANmetRics workflow. It does not classify buildings (this is handled
in [`building_structure()`](building_structure.md)), but instead
computes geometric and density-based metrics for each building category.

The modular design ensures:

- consistent metric definitions across domains,

- reproducibility,

- separation of concerns between structure extraction and metric
  computation.

## Examples

``` r
if (FALSE) { # \dontrun{
buildings <- building_structure(aoi)
metrics <- building_metrics(buildings, aoi)
metrics$summary
} # }
```
