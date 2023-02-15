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
  layers text[] NOT NULL,
  tile bytea NOT NULL,
  profile text NOT NULL REFERENCES tile_cache.profile(name),
  tms text NOT NULL REFERENCES tile_utils.tms_definition(name) DEFAULT current_setting('tile_utils.default_tms'),
  created timestamp without time zone NOT NULL DEFAULT now(),
  last_used timestamp without time zone NOT NULL DEFAULT now(),
  PRIMARY KEY (x, y, z, layers),
  -- Make sure tile is within TMS bounds
  CHECK (x >= 0 AND y >= 0 AND z >= 0 AND x < 2^z AND y < 2^z)
);
