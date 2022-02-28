CREATE OR REPLACE FUNCTION tile_utils.tms_bounds(
  _tms text = null
) RETURNS geometry(Polygon)
AS $$
  SELECT bounds
  FROM imagery.tms
  WHERE name = coalesce(
    _tms,
    current_setting('tile_utils.default_tms')
  )
);
$$
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION tils_utils.tms_srid(tms text = null)
  RETURNS integer
AS $$
  SELECT ST_SRID(tile_utils.tms_bounds(tms));
$$ LANGUAGE SQL IMMUTABLE;


CREATE OR REPLACE FUNCTION
  tile_utils._tile_envelope(
    _x integer,
    _y integer,
    _z integer,
    _tms text = null
  ) RETURNS geometry(Polygon)
AS $$
  SELECT ST_TileEnvelope(
    _z, _x, _y,
    tile_utils.tms_bounds(_tms)
  );
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION
  tile_utils.tile_envelope(
    _x integer,
    _y integer,
    _z integer,
    _tms text = null 
  ) RETURNS geometry(Polygon)
AS $$
  SELECT ST_Transform(
    imagery._tile_envelope(_x, _y, _z, _tms),
    imagery.
  );
$$ LANGUAGE SQL;


-- This currently only works for square tiles.
CREATE OR REPLACE FUNCTION tile_utils.tile_index(
  coord numeric,
  z integer,
  _tms text = 'mars_mercator'
) RETURNS integer AS $$
DECLARE
  _tms_bounds geometry;
  _geom_bbox box2d;
  _tms_size numeric;
  _tile_size numeric;
BEGIN
  SELECT bounds FROM imagery.tms WHERE name = _tms INTO _tms_bounds;
  _tms_size := ST_XMax(_tms_bounds) - ST_XMin(_tms_bounds);
  _tile_size := _tms_size/(2^z);

  RETURN floor(coord/_tile_size)::integer;
END;
$$ LANGUAGE PLPGSQL STABLE;


CREATE OR REPLACE FUNCTION tile_utils.containing_tiles(
  _geom geometry,
  _tms text = 'mars_mercator'
) RETURNS TABLE (
  x integer,
  y integer,
  z integer
) AS $$
DECLARE
  _tms_bounds geometry;
  _geom_bbox box2d;
BEGIN
  SELECT bounds FROM imagery.tms WHERE name = _tms INTO _tms_bounds;

  IF ST_Within(_geom, ST_Transform(_tms_bounds, ST_SRID(_geom))) THEN
    _geom_bbox := ST_Transform(_geom, ST_SRID(_tms_bounds))::box2d;
  ELSE
    RETURN;
  END IF;

  RETURN QUERY
  WITH tile_sizes AS (
    SELECT
      a.zoom
    FROM generate_series(0, 24) AS a(zoom)
  ), tilebounds AS (
    SELECT t.zoom,
      tile_utils.tile_index((ST_XMin(_geom_bbox)-ST_XMin(_tms_bounds))::numeric, t.zoom) xmin,
      tile_utils.tile_index((ST_YMax(_tms_bounds)-ST_YMin(_geom_bbox))::numeric, t.zoom) ymin,
      tile_utils.tile_index((ST_XMax(_geom_bbox)-ST_XMin(_tms_bounds))::numeric, t.zoom) xmax,
      tile_utils.tile_index((ST_YMax(_tms_bounds)-ST_YMax(_geom_bbox))::numeric, t.zoom) ymax
    FROM tile_sizes t
  )
  SELECT
    t.xmin::integer x,
    t.ymin::integer y,
    t.zoom::integer z
  FROM tilebounds t
  WHERE t.xmin = t.xmax
    AND t.ymin = t.ymax
  ORDER BY z DESC;
END;  
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION tile_utils.parent_tile(
  _geom geometry,
  _tms text = 'mars_mercator'
) RETURNS TABLE (
  x integer,
  y integer,
  z integer
) AS $$
  SELECT x, y, z FROM tile_utils.containing_tiles(_geom, _tms) LIMIT 1;
$$ LANGUAGE sql STABLE;
