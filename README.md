# Macrostrat tile utilities

Utility functions for map-tile calculations and caching directly in a PostGIS database.
The functions here are designed to support a variety of dynamic tiling tasks, including:

- Getting the correct extents and CRS information for a given tile
- Setting feature visibility, simplification, and clustering based on zoom level
- Finding containing tiles for a given feature

Also included are tables and functions supporting a simple tile-caching system backed
by a PostGIS table (similar to an MBTiles SQLite database). Using triggers + the
utility functions above, this will support simple
expiry and updating, easing management of a large tile cache.

This software is heavily inspired by [Mapbox's `postgis-vt-util`](https://github.com/mapbox/postgis-vt-util).
However, like the [`morecantile` Python library](https://github.com/developmentseed/morecantile/), it supports
multiple TMS definitions, making it suitable for use in planetary as well as Earth-based applications.

## Usage

Simply run the SQL contained in this repository against your PostGIS
database (v11 or greater likely needed). This will create functions
in the `tile_utils` namespace. If the appropriate files are read in,
the `tile_cache` schema will be defined as well.

