# Predefined OSM green-space tags

A named list of OSM key–value pairs used by
[`green_structure()`](green_structure.md) to extract green-space
features from OpenStreetMap. This list is part of the public API of the
URBANmetRics package and can be reused or extended by users to define
custom green-space tag sets.

## Usage

``` r
green_tags
```

## Format

A named list of three character vectors.

## Details

The list contains three OSM keys commonly associated with vegetation,
parks, natural areas, and other forms of urban green space:

- leisure:

  OSM `leisure=*` values representing recreational green areas such as
  parks, gardens, allotments, and nature reserves.

- landuse:

  OSM `landuse=*` values representing vegetated land uses such as
  forest, meadow, orchard, or cemetery.

- natural:

  OSM `natural=*` values representing natural vegetation types such as
  wood, grassland, scrub, or heath.

## Examples

``` r
green_tags
#> $leisure
#> [1] "park"              "dog_park"          "garden"           
#> [4] "allotments"        "nature_reserve"    "recreation_ground"
#> 
#> $landuse
#> [1] "forest"        "grass"         "meadow"        "village_green"
#> [5] "orchard"       "cemetery"     
#> 
#> $natural
#> [1] "wood"      "grassland" "scrub"     "heath"    
#> 
```
