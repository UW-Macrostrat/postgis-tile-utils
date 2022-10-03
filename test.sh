#!/usr/bin/env bash

# passcount=0
# failcount=0
# runcount=0
# testtotal=$(grep -c '^tf ' "$0")

dbname="postgres"

# Wait for database
while ! pg_isready -q -U postgres -d $dbname; do
  echo "Waiting for database..."
  sleep 1
done

psqld="psql -AtqX -U postgres -d $dbname"

# Create schemas
sqldir=/sql
for f in $(find $sqldir -name '*.sql'); do
  echo "Applying SQL file $f"
  $psqld -f $f
done

# This is a demonstration test, at this point
# Test cluster expansion zoom
sql="SELECT tile_utils.cluster_expansion_zoom('MULTIPOINT(40 40, 20 21)', 10)"
res=14
if [[ $($psqld -c "$sql") == $res ]]; then
  echo "cluster_expansion_zoom: pass"
  # ((passcount++))
else
  echo "cluster_expansion_zoom: fail"
  # ((failcount++))
fi
