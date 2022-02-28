CREATE SCHEMA IF NOT EXISTS tile_utils;

CREATE TABLE IF NOT EXISTS tile_utils.tms_defs (
  name text PRIMARY KEY,
  bounds geometry(Polygon),
  geographic_srid integer,
);

INSERT INTO tile_utils.tms_defs (name, bounds, geographic_srid) VALUES (
  'web_mercator',
  ST_TileEnvelope(0, 0, 0),
  4325
) ON CONFLICT DO NOTHING;

SET tile_utils.default_tms = 'web_mercator'; 

