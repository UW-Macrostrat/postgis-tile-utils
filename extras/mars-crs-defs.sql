INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text)
VALUES (
  949900,
  'USER',
  949900,
  'GEOGCS[
    "GCS_Mars_2000_Sphere",
    DATUM[
      "Mars_2000_(Sphere)",
      SPHEROID["Mars_2000_Sphere_IAU_IAG",3396190,0],
      AUTHORITY["ESRI","106971"]
    ],
    PRIMEM["Reference_Meridian",0],
    UNIT["Degree",0.0174532925199433],
    AXIS["Longitude",EAST],
    AXIS["Latitude",NORTH]
  ]',
  '+proj=longlat +R=3396190 +no_defs'
),  
(
  949901,
  'USER',
  949901,
  'PROJCS[
  "Mars 2000 / Pseudo-Mercator",
  GEOGCS[
    "GCS_Mars_2000_Sphere",
    DATUM[
      "Mars_2000_(Sphere)",
      SPHEROID["Mars_2000_Sphere_IAU_IAG",3396190,0],
      AUTHORITY["ESRI","106971"]
    ],
    PRIMEM["Reference_Meridian",0],
    UNIT["Degree",0.0174532925199433],
    AXIS["Longitude",EAST],
    AXIS["Latitude",NORTH]
  ],
  PROJECTION["Mercator_1SP"],
  PARAMETER["central_meridian",0],
  PARAMETER["scale_factor",1],
  PARAMETER["false_easting",0],
  PARAMETER["false_northing",0],
  UNIT["metre",1,AUTHORITY["EPSG","9001"]],
  AXIS["X",EAST],
  AXIS["Y",NORTH],
  EXTENSION["PROJ4","+proj=merc +a=3396190 +b=3396190 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +no_defs"],
  AUTHORITY["EPSG","3857"]
]',
'+proj=merc +a=3396190 +b=3396190 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +no_defs'
) ON CONFLICT DO NOTHING;

INSERT INTO tile_utils.tms_definition (name, bounds, geographic_srid) VALUES (
  'mars_mercator',
  ST_SetSRID(ST_MakeEnvelope(-10669445.554195097, -10669445.554195097, 10669445.554195097, 10669445.554195097), 949901),
  949900
) ON CONFLICT DO NOTHING;

-- Replace default TMS function
CREATE OR REPLACE FUNCTION tile_utils.default_tms() 
RETURNS text AS $$ SELECT 'mars_mercator'; $$
LANGUAGE SQL;
