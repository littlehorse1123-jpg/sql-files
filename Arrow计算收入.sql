SELECT
          params
        --   json_extract_scala(params, 'ip') AS ip
     
        FROM pub_1805.arrowpuzzle_android
        WHERE dt = '2026-06-25'
            AND event_name = 'IPD'
        limit 100
;


select * from pub_1805.arrowpuzzle_android;



select distinct event_name  from pub_1805.arrowpuzzle_android 
where dt = '2026-06-25' ;


WITH t AS (
    SELECT json_extract_scalar(params, '$.msg') AS msg
    FROM pub_1805.arrowpuzzle_android
)
SELECT 
    regexp_extract(msg, 'adFormat=''([^'']*)''', 1) AS adFormat,
    regexp_extract(msg, 'adUnit=''([^'']*)''', 1) AS adUnit,
    regexp_extract(msg, 'adNetwork=''([^'']*)''', 1) AS adNetwork,
    regexp_extract(msg, 'revenue=([0-9.E+-]+)', 1) AS revenue,   -- 提取数字
    regexp_extract(msg, 'country=''([^'']*)''', 1) AS country
FROM t;


-------------------------------------------------------------------------------------

WITH raw AS (
    SELECT
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        msg,
        mdi,
        -- adFormat（保持不变）
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        -- adUnit（保持不变）
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        -- networkName（保持不变）
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,
        
        -- 修正后的 revenue 处理（核心）
        COALESCE(
            REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([0-9,]+[,.][0-9Ee+\-]+)(?:,|\s|$)', 1),
            REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([0-9,]+)(?:,|\s|$)', 1)
        ) AS revenue_str,
        
        TRY_CAST(
            REPLACE(  -- 全局替换所有逗号为点号
                COALESCE(
                    REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([0-9,]+[,.][0-9Ee+\-]+)(?:,|\s|$)', 1),
                    REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([0-9,]+)(?:,|\s|$)', 1)
                ),
                ',', 
                '.'
            ) AS DOUBLE
        ) AS revenue
    FROM raw
)
SELECT
    adFormat,
    mdi,
    adUnit,
    networkName,
    revenue,        -- 现在将正确返回数值（如 0.0000113827）
    revenue_str,    -- 原始字符串（用于验证）
    msg
FROM cleaned
LIMIT 100;

--------------------------------------------------最终落定版本-----------------------------------------------


WITH raw AS (
    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        dt,
        msg,
        mdi,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,

        -- 统一匹配：小数 / 科学计数法 / 带逗号千分位
        REGEXP_EXTRACT(
            msg,
            'revenue\s*[:=]\s*([+-]?[0-9]+[.,]?[0-9]*([Ee][+-]?[0-9]+)?)',
            1
        ) AS revenue_str,

        -- 先把逗号转成点，再转 double
        TRY_CAST(
            REPLACE(
                REGEXP_EXTRACT(
                    msg,
                    'revenue\s*[:=]\s*([+-]?[0-9]+[.,]?[0-9]*([Ee][+-]?[0-9]+)?)',
                    1
                ),
                ',',
                '.'
            ) AS DOUBLE
        ) AS revenue

    FROM raw
)
SELECT
    dt,
    adFormat,
    mdi,
    adUnit,
    networkName,
    revenue,
    revenue_str,
    msg
FROM cleaned
where adFormat = 'banner'
;



----------------------------------------------------------


WITH raw AS (
    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt >= '2026-05-28'
      AND dt <= '2026-06-28'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        dt,
        msg,
        mdi,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,

        -- 统一匹配：小数 / 科学计数法 / 带逗号千分位
        REGEXP_EXTRACT(
            msg,
            'revenue\s*[:=]\s*([+-]?[0-9]+[.,]?[0-9]*([Ee][+-]?[0-9]+)?)',
            1
        ) AS revenue_str,

        -- 先把逗号转成点，再转 double
        TRY_CAST(
            REPLACE(
                REGEXP_EXTRACT(
                    msg,
                    'revenue\s*[:=]\s*([+-]?[0-9]+[.,]?[0-9]*([Ee][+-]?[0-9]+)?)',
                    1
                ),
                ',',
                '.'
            ) AS DOUBLE
        ) AS revenue

    FROM raw
)
SELECT
    dt,
    -- adFormat,
    CASE
        WHEN UPPER(adFormat) IN ('INTERSTITIAL', 'INTER') THEN '插屏'
        WHEN UPPER(adFormat) IN ('REWARDED_VIDEO', 'REWARDED') THEN '激励视频'
        ELSE adFormat  -- 其他原样返回
    END AS adFormat_name,
    mdi,
    -- adUnit,
    -- networkName,
    CASE
            -- 谷歌系
            WHEN UPPER(networkName) IN ('ADMANAGER', 'GOOGLE AD MANAGER') THEN 'Google Ad Manager'
            WHEN UPPER(networkName) IN ('ADMOB', 'GOOGLE ADMOB') THEN 'Google AdMob'
            
            -- AppLovin 系
            WHEN UPPER(networkName) IN ('APPLOVIN', 'APPLOVIN_EXCHANGE') THEN 'AppLovin'
            
            -- Meta
            WHEN UPPER(networkName) IN ('FACEBOOK') THEN 'Meta'
            
            -- DT Exchange / Fyber
            WHEN UPPER(networkName) IN ('FYBER', 'DT EXCHANGE') THEN 'DT Exchange'
            
            -- ironSource 系
            WHEN UPPER(networkName) IN ('IRONSOURCEADS', 'IRONSOURCE') THEN 'ironSource'
            
            -- 其他直接统一
            WHEN UPPER(networkName) IN ('MINTEGRAL') THEN 'Mintegral'
            WHEN UPPER(networkName) IN ('MOLOCO') THEN 'Moloco'
            WHEN UPPER(networkName) IN ('PANGLE') THEN 'Pangle'
            WHEN UPPER(networkName) IN ('UNITYADS', 'UNITY ADS') THEN 'Unity Ads'
            WHEN UPPER(networkName) IN ('VUNGLE') THEN 'Vungle'
            WHEN UPPER(networkName) IN ('LIFTOFF MONETIZE') THEN 'Liftoff Monetize'
            
            ELSE networkName
        END AS standard_network,
    sum(revenue) as  revenue,
    count(1) as pv

FROM cleaned
group by dt,
    CASE
        WHEN UPPER(adFormat) IN ('INTERSTITIAL', 'INTER') THEN '插屏'
        WHEN UPPER(adFormat) IN ('REWARDED_VIDEO', 'REWARDED') THEN '激励视频'
        ELSE adFormat  -- 其他原样返回
    END ,
    mdi,
    CASE
            -- 谷歌系
            WHEN UPPER(networkName) IN ('ADMANAGER', 'GOOGLE AD MANAGER') THEN 'Google Ad Manager'
            WHEN UPPER(networkName) IN ('ADMOB', 'GOOGLE ADMOB') THEN 'Google AdMob'
            
            -- AppLovin 系
            WHEN UPPER(networkName) IN ('APPLOVIN', 'APPLOVIN_EXCHANGE') THEN 'AppLovin'
            
            -- Meta
            WHEN UPPER(networkName) IN ('FACEBOOK') THEN 'Meta'
            
            -- DT Exchange / Fyber
            WHEN UPPER(networkName) IN ('FYBER', 'DT EXCHANGE') THEN 'DT Exchange'
            
            -- ironSource 系
            WHEN UPPER(networkName) IN ('IRONSOURCEADS', 'IRONSOURCE') THEN 'ironSource'
            
            -- 其他直接统一
            WHEN UPPER(networkName) IN ('MINTEGRAL') THEN 'Mintegral'
            WHEN UPPER(networkName) IN ('MOLOCO') THEN 'Moloco'
            WHEN UPPER(networkName) IN ('PANGLE') THEN 'Pangle'
            WHEN UPPER(networkName) IN ('UNITYADS', 'UNITY ADS') THEN 'Unity Ads'
            WHEN UPPER(networkName) IN ('VUNGLE') THEN 'Vungle'
            WHEN UPPER(networkName) IN ('LIFTOFF MONETIZE') THEN 'Liftoff Monetize'
            
            ELSE networkName
        END 
;


------------------------------------替换斜杠-------------------------------------------------------


WITH raw AS (
    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        dt,
        msg,
        mdi,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,

        -- 统一匹配：小数 / 科学计数法 / 带逗号千分位
        REGEXP_EXTRACT(
            msg,
            'revenue\s*[:=]\s*([+-]?[0-9]+[.,]?[0-9]*([Ee][+-]?[0-9]+)?)',
            1
        ) AS revenue_str,
        
        -- 按聚合类型提取 revenue 字符串
        CASE
            WHEN mdi = 'LevelPlay'
                THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
            WHEN mdi = 'MAX'
                THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
            ELSE NULL
        END AS revenue_str,

        -- 统一替换 / 和 , 为 .，转 double
        TRY_CAST(
            REPLACE(
                REPLACE(
                    CASE
                        WHEN mdi = 'LevelPlay'
                            THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
                        WHEN mdi = 'MAX'
                            THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
                        ELSE NULL
                    END,
                    '/', '.'
                ),
                ',', '.'
            ) AS DOUBLE
        ) AS revenue

    FROM raw
)
SELECT
    dt,
    adFormat,
    mdi,
    networkName,
    revenue,
    revenue2,
    revenue_str,
    msg
    -- sum(revenue) as revenue

FROM cleaned
where adFormat = 'banner'
and networkName = 'admob'
and mdi = 'LevelPlay'
order by revenue desc
limit 1000
-- group by dt,
--     adFormat,
--     mdi,
--     networkName
;



----------------------------------------------------------计算收入最终版----------------------------------------------------------
WITH raw AS (
    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        dt,
        msg,
        mdi,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,

        
        -- 按聚合类型提取 revenue 字符串
        CASE
            WHEN mdi = 'LevelPlay'
                THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
            WHEN mdi = 'MAX'
                THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
            ELSE NULL
        END AS revenue_str,

        -- 统一替换 / 和 , 为 .，转 double
        TRY_CAST(
            REPLACE(
                REPLACE(
                    CASE
                        WHEN mdi = 'LevelPlay'
                            THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
                        WHEN mdi = 'MAX'
                            THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
                        ELSE NULL
                    END,
                    '/', '.'
                ),
                ',', '.'
            ) AS DOUBLE
        ) AS revenue

    FROM raw
)
SELECT
    dt,
    adFormat,
    mdi,
    networkName,
    revenue,
    revenue_str,
    msg
    -- sum(revenue) as revenue

FROM cleaned
where adFormat = 'banner'
-- and networkName = 'admob'
and mdi = 'LevelPlay'
order by revenue asc
limit 1000
-- group by dt,
--     adFormat,
--     mdi,
--     networkName
;



    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
    ;


      SELECT
        dt,
        count(distinct id) as cnt_uid 
    FROM pub_1701.watersort_android_signup
    WHERE dt >= '2026-06-25'
    group by dt
    ;



    SELECT
        count(distinct bundle_id) as cnt_bundle ,
        count(distinct advertising_id) as cnt_uid
    FROM pub_1701.watersort_android_signup
    WHERE dt = '2026-06-25'
 limit 10
 ;



     SELECT 
    dt,
    count(distinct id) as cnt_bundle 

    FROM pub_1701.watersort_ios
    WHERE dt >= '2026-05-26'
    and event_name = 'APST'
    group by dt
    -- limit 100

;


--SELECT json_extract_scalar(params, '$.msg') AS msg

with base_info as 
(
    SELECT 
    dt,
    event_name,
    json_extract_scalar(params, '$.msg') AS msg

 FROM pub_1701.watersort_ios
    WHERE dt = '2026-05-26'

)
SELECT 
    regexp_extract(msg, 'adFormat=''([^'']*)''', 1) AS adFormat,
    regexp_extract(msg, 'adUnit=''([^'']*)''', 1) AS adUnit,
    regexp_extract(msg, 'adNetwork=''([^'']*)''', 1) AS adNetwork,
    regexp_extract(msg, 'revenue=([0-9.E+-]+)', 1) AS revenue,   -- 提取数字
    regexp_extract(msg, 'country=''([^'']*)''', 1) AS country
FROM base_info

;






SELECT 
     dt,
     substr(base_time,1,10) as base_time,
     substr(install_time,1,10) as install_date
    FROM pub_1701.watersort_ios
    WHERE dt = '2026-05-26'
    and event_name = 'SBBQ'
    limit 100
 ;
 

 SELECT 
    dt,
    substr(base_time, 1, 10) AS base_time,
    substr(install_time, 1, 10) AS install_date,
    
    -- 带正负的天数差（base_time - install_date）
    datediff(
        to_date(substr(base_time, 1, 10)),
        to_date(substr(install_time, 1, 10))
    ) AS day_diff_with_sign,
    json_extract_scalar(json_extract_scalar(params, '$.msg'),'$.adFormat') as adFormat,
    json_extract_scalar(json_extract_scalar(params, '$.msg'),'$.revenue') AS msg

FROM pub_1701.watersort_ios
WHERE dt = '2026-05-26'
  AND event_name = 'SBBQ'  -- 你这里是空字符串，自己按需改
LIMIT 100;


-----------------------------------------------------------


WITH raw AS (
    SELECT
        dt,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi
    FROM pub_1805.arrowpuzzle_android
    WHERE dt = '2026-06-25'
      AND event_name = 'IPD'
),
cleaned AS (
    SELECT
        dt,
        msg,
        mdi,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat,
        COALESCE(
            regexp_extract(msg, 'adUnit=''([^'']*)''', 1),
            regexp_extract(msg, 'adUnitIdentifier:\s*([^,\]]+)', 1)
        ) AS adUnit,
        COALESCE(
            regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
            regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
        ) AS networkName,

        
        -- 按聚合类型提取 revenue 字符串
        CASE
            WHEN mdi = 'LevelPlay'
                THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
            WHEN mdi = 'MAX'
                THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
            ELSE NULL
        END AS revenue_str,

        -- 统一替换 / 和 , 为 .，转 double
        TRY_CAST(
            REPLACE(
                REPLACE(
                    CASE
                        WHEN mdi = 'LevelPlay'
                            THEN regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1)
                        WHEN mdi = 'MAX'
                            THEN REGEXP_EXTRACT(msg, 'revenue\s*[:=]\s*([+-]?[0-9/.,Ee+-]+)', 1)
                        ELSE NULL
                    END,
                    '/', '.'
                ),
                ',', '.'
            ) AS DOUBLE
        ) AS revenue

    FROM raw
)
SELECT
    dt,
    adFormat,
    mdi,
    networkName,
    revenue,
    revenue_str,
    msg
    -- sum(revenue) as revenue

FROM cleaned
where adFormat = 'banner'
-- and networkName = 'admob'
and mdi = 'LevelPlay'
order by revenue asc
limit 1000
-- group by dt,
--     adFormat,
--     mdi,
--     networkName
;



WITH raw AS (
    SELECT
        dt,
        bundle_id,
        json_extract_scalar(params, '$.msg') AS msg,
        json_extract_scalar(params, '$.mdi') AS mdi

    FROM pub_1805.arrowpuzzle_ios
    WHERE dt >= '2026-06-20'
      AND event_name = 'IPD'
)

SELECT
        dt,
        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) AS adFormat
        count(distinct bundle_id)

FROM raw

group  by dt,        COALESCE(
            regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
            regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
        ) 
    