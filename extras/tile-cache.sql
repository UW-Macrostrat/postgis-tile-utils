CREATE SCHEMA tile_cache;

CREATE TABLE IF NOT EXISTS tile_cache.profile (
  name text NOT NULL PRIMARY KEY,
  format text NOT NULL,
  content_type text NOT NULL,
  minzoom integer,
  maxzoom integer
);

/* We need to add a TMS column to support non-mercator tiles */
CREATE TABLE IF NOT EXISTS tile_cache.tile (
  x integer NOT NULL,
  y integer NOT NULL,
  z integer NOT NULL,
  profile text NOT NULL REFERENCES tile_cache.profile(name),
  -- Hash of the params
  params bytea NOT NULL,
  /* TODO: we could cache each layer separately and merge in the tile server */
  --layers text[] NOT NULL,
  tile bytea NOT NULL,
  tms text NOT NULL REFERENCES tile_utils.tms_definition(name) DEFAULT tile_utils.default_tms(),
  created timestamp without time zone NOT NULL DEFAULT now(),
  last_used timestamp without time zone NOT NULL DEFAULT now(),
  PRIMARY KEY (x, y, z, params, profile),
  -- Make sure tile is within TMS bounds
  CHECK (x >= 0 AND y >= 0 AND z >= 0 AND x < 2^z AND y < 2^z)
);


CREATE INDEX IF NOT EXISTS tile_cache_tile_last_used_idx ON tile_cache.tile (last_used);

CREATE OR REPLACE VIEW tile_cache.tile_info AS
SELECT 
  x,
  y,
  z,
  profile,
  params,
  length(tile) tile_size,
  tms,
  created,
  last_used
FROM tile_cache.tile;

CREATE OR REPLACE FUNCTION tile_cache.remove_excess_tiles(max_size bigint DEFAULT 100000) RETURNS void AS $$
DECLARE
  _current_size bigint;
  _num_deleted integer;
BEGIN
  /** Delete the most stale tiles until fewer than max_size tiles remain. */
  -- Get approximate size of cache
  SELECT pg_total_relation_size('tile_cache.tile') INTO _current_size;
  
  -- Get approximate number of tiles in cache table (without full table scan)
  SELECT reltuples::bigint AS estimate
  FROM pg_class
  WHERE oid = 'tile_cache.tile'::regclass
  INTO _current_size;

  -- Delete tiles until cache size is less than max_size
  _num_deleted := _current_size - max_size;

  IF _current_size > max_size THEN
    DELETE FROM tile_cache.tile
    WHERE last_used < (
      SELECT last_used FROM tile_cache.tile
      ORDER BY last_used ASC
      LIMIT 1
      OFFSET _num_deleted
    );

    RAISE NOTICE 'Deleted % tiles to reduce cache size', _num_deleted;
  END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;
