{{ config(materialized='ephemeral') }}

WITH
src_data as (
    SELECT
    NAME                 as EXCHANGE_NAME             -- TEXT
    ,ID                  as EXCHANGE_CODE             -- TEXT
    ,COUNTRY             as COUNTRY_NAME              -- TEXT
    ,CITY                as CITY_NAME                 -- TEXT
    ,ZONE                as ZONE_NAME                 -- TEXT
    ,DELTA               as DELTA                     -- FLOAT
    ,DST_PERIOD          as DST_PERIOD                -- TEXT
    ,OPEN                as OPEN_TIME                 -- TEXT
    ,CLOSE               as CLOSE_TIME                -- TEXT
    ,LUNCH               as LUNCH_TIME                -- TEXT
    ,OPEN_UTC            as OPEN_UTC_TIME             -- TEXT
    ,CLOSE_UTC           as CLOSE_UTC_TIME            -- TEXT
    ,LUNCH_UTC           as LUNCH_UTC_TIME            -- TEXT
    ,LOAD_TS             as LOAD_TS                   -- TIMESTAMP_NTZ
    , 'SEED.ABC_Bank_EXCHANGE' as RECORD_SOURCE
    FROM {{ source('seeds', 'ABC_Bank_EXCHANGE') }}
 ),

 default_record as (
  SELECT
      'Missing'             as EXCHANGE_NAME
    , '-1'                  as EXCHANGE_CODE
    , 'Missing'             as COUNTRY_NAME
    , 'Missing'             as CITY_NAME
    , 'Missing'             as ZONE_NAME
    , -1.0                  as DELTA
    , 'Missing'             as DST_PERIOD
    , 'Missing'             as OPEN_TIME
    , 'Missing'             as CLOSE_TIME
    , 'Missing'             as LUNCH_TIME
    , 'Missing'             as OPEN_UTC_TIME
    , 'Missing'             as CLOSE_UTC_TIME
    , 'Missing'             as LUNCH_UTC_TIME
    , '2020-01-01'          as LOAD_TS_UTC
    , 'System.DefaultKey'   as RECORD_SOURCE
),

with_default_record as(
    SELECT * FROM src_data
    UNION ALL
    SELECT * FROM default_record
),

hashed as (
    SELECT
          concat_ws('|', EXCHANGE_CODE) as EXCHANGE_HKEY
        , concat_ws('|', EXCHANGE_CODE,
                         EXCHANGE_NAME, COUNTRY_NAME,
                         CITY_NAME, ZONE_NAME, DELTA,
                         DST_PERIOD,
                         OPEN_UTC_TIME, CLOSE_UTC_TIME,
                         LUNCH_UTC_TIME)
                as EXCHANGE_HDIFF
        , * EXCLUDE LOAD_TS
        , LOAD_TS as LOAD_TS_UTC
    FROM src_data
)

SELECT * FROM hashed