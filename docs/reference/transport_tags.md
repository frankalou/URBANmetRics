# Predefined OSM transport tags

A named list of OSM key–value pairs used by
[`transport_structure()`](transport_structure.md) to extract
transport-related features from OpenStreetMap. This list is part of the
public API of the URBANmetRics package and can be reused or extended by
users to define custom transport tag sets.

## Usage

``` r
transport_tags
```

## Format

A named list of three logical TRUE entries.

## Details

The list contains three OSM keys commonly associated with transport
infrastructure, including roads, railways, and public transport
elements:

- highway:

  Logical TRUE, meaning all `highway=*` values are matched.

- railway:

  Logical TRUE, meaning all `railway=*` values are matched.

- public_transport:

  Logical TRUE, meaning all `public_transport=*` values are matched.

## Examples

``` r
transport_tags
#> $highway
#> [1] TRUE
#> 
#> $railway
#> [1] TRUE
#> 
#> $public_transport
#> [1] TRUE
#> 
```
