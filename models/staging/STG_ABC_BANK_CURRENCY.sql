{{ config(materialized='ephemeral') }}

WITH
src_data as (
    SELECT
    ALPHABETICCODE              as ALPHABETIC_CODE      -- TEXT
    , NUMERICCODE               as CURRENCY_CODE        -- NUMBER
    , DECIMALDIGITS             as DIGITS               -- NUMBER
    , CURRENCYNAME              as CURRENCY_NAME        -- TEXT
    , LOCATIONS                 as LOCATIONS_NAME       -- TEXT
    , LOAD_TS                   as LOAD_TS              -- TIMESTAMP_NTZ
    , 'SEED.ABC_Bank_CURRENCY'  as RECORD_SOURCE
    FROM {{ source('seeds', 'ABC_Bank_CURRENCY') }}
 ),

 default_record as (
  SELECT
      'Missing'             as ALPHABETIC_CODE
    , '-1'                  as CURRENCY_CODE
    , -1.0                  as DIGITS
    , 'Missing'             as CURRENCY_NAME
    , 'Missing'             as LOCATIONS_NAME
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
          concat_ws('|', CURRENCY_CODE) as CURRENCY_HKEY
        , concat_ws('|', CURRENCY_CODE,
                         ALPHABETIC_CODE, DIGITS,
                         CURRENCY_NAME, LOCATIONS_NAME)
                as CURRENCY_HDIFF
        , * EXCLUDE LOAD_TS
        , LOAD_TS as LOAD_TS_UTC
    FROM src_data
)

SELECT * FROM hashed