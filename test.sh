#!/usr/bin/env bash

passcount=0
failcount=0
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

function run-test() {
  name=$1
  sql=$2
  res=$3
  echo "Running test $name"
  echo "> $sql"
  out=$($psqld -c "$sql")
  echo -n "--> ${out:-"null"}"
  if [[ "$out" == "$res" ]]; then
    echo " == ${res:-null}"
    echo "$name: pass"
    ((passcount++))
  else
    echo " != ${res:-null}"
    echo "$name: fail"
    ((failcount++))
  fi
  echo ""
}

echo -e "\n\nRunning tests..."

run-test "cluster_expansion_zoom" \
  "SELECT tile_utils.cluster_expansion_zoom('MULTIPOINT(40 40, 20 21)', 10)" \
  14

run-test "cluster_expansion_zoom (single point)" \
  "SELECT tile_utils.cluster_expansion_zoom('POINT(40 40)', 10)" \
  ""

echo "$passcount tests passed, $failcount tests failed"