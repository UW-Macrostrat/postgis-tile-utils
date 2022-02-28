#!/usr/bin/env bash

# passcount=0
# failcount=0
# runcount=0
# testtotal=$(grep -c '^tf ' "$0")

dbname="postgis_tile_utils_tests"

createdb "$dbname"

psqld="psql -AtqX -d $dbname"
$psqld -f "$(dirname "$0")/sql/tile-utils.sql"

dropdb "$dbname"