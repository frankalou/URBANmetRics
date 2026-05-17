# Predefined OSM building tags

A named list of OSM key–value pairs used by
[`building_structure()`](building_structure.md) to extract building
features from OpenStreetMap.

## Usage

``` r
building_tags
```

## Format

A named list with one element:

- building:

  Logical TRUE, meaning all `building=*` values are matched

## Examples

``` r
building_tags
#> $building
#> [1] TRUE
#> 
```
