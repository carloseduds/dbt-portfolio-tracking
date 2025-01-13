{% snapshot SNSH_ABC_BANK_EXCHANGE %}

{{
    config(
      unique_key= 'EXCHANGE_HKEY',
      strategy='check',
      check_cols=['EXCHANGE_HDIFF'],        
    )
}}
SELECT * FROM {{ ref("STG_ABC_BANK_EXCHANGE") }}

{% endsnapshot %}