   
   ---Arrow Android 的广告统计
     WITH raw AS (  
                SELECT
                  dt,   
                  json_extract_scalar(params, '$.msg') AS msg, 
                  json_extract_scalar(params, '$.mdi') AS mdi    
               FROM pub_1805.arrowpuzzle_android 
               WHERE dt >= '2026-06-20' 
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
                     regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
                     regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
                  ) AS networkName,
                  -- 统一替换 / 和 , 为 .，转 double
                  TRY_CAST(
                     REPLACE(
                        REPLACE(
                           CASE
                              WHEN mdi = 'LevelPlay'
                                 THEN regexp_extract(msg, 'revenue=(.+?),\s*precision', 1)
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
    select
            a.dt,
            a.adFormat,
            a.adNetworkType,
            sum(a.revenue) as revenue,
            count(1) as pv

    from cleaned a

    group by a.dt,
            a.adFormat,
            a.adNetworkType

;





----分格式，分network
-- 老用户占比变高


