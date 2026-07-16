-- try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,


     WITH raw AS (  
                SELECT
                  dt,   
                  json_extract_scalar(params, '$.msg') AS msg, 
                  try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
                  json_extract_scalar(params, '$.mdi') AS mdi,
                  try_cast(json_extract_scalar(params, '$.def') as double) AS revenue   

               FROM pub_1805.arrowpuzzle_android 
               WHERE dt >= '2026-07-09' 
               AND event_name = 'IPD' 
    ), 
    cleaned AS (  

            SELECT
                  dt,
                  mdi,
                  day_diff_with_sign,
                  COALESCE(
                     regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
                     regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
                  ) AS adFormat,
                  COALESCE(
                     regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
                     regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
                  ) AS networkName,
                  -- 统一替换 / 和 , 为 .，转 double
                  revenue
            FROM raw
     ) 
    select 
        dt,
        mdi,
        adFormat,
        networkName,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        sum(revenue) as revenue,
        count(1) as pv
    from cleaned

    group by dt,
        mdi,
        adFormat,
        networkName,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END 
;



--------------------------启动DAU----------------

WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign 

               FROM pub_1805.arrowpuzzle_android 
               WHERE dt >= '2026-07-03' 
               AND event_name = 'APLS' 
    )

    select 
        dt,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        count(distinct bundle_id)

    from cleaned

    group by dt,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END 
;



WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign 

               FROM pub_1805.arrowpuzzle_android 
               WHERE dt >= '2026-07-03' 
               AND event_name = 'APLS' 
    )

    select 
        dt,
        count(distinct bundle_id)

    from cleaned

    group by dt
;



-----------------------------------------------------填充--------------------------------------

with load_start as
(
           SELECT
            dt,
            bundle_id,
            event_name,
            country,
            json_extract_scalar(params, '$.unt') as unit,
            json_extract_scalar(params, '$.attempt_id') as attempt_id
  
        FROM pub_1805.arrowpuzzle_android 
        WHERE dt >= '2026-06-21'
        and dt <=  '2026-07-04'
        AND event_name IN ('ILB' ) 

),
load_end as
(
           SELECT
            dt,
            bundle_id,
            event_name,
            json_extract_scalar(params, '$.unt') as unit,
            json_extract_scalar(params, '$.attempt_id') as attempt_id,
            try_cast(json_extract_scalar(params, '$.rvn') as double) as rvn
  
        FROM pub_1805.arrowpuzzle_android 
        WHERE dt >= '2026-06-21' 
        and dt <=  '2026-07-04'
        AND event_name in ('ILS')  
)
 
select
    load_start.dt,
    -- load_start.bundle_id,
    load_start.unit,
    load_start.event_name as load_start_event_name,
    CASE                                                         
            WHEN country = 'US' THEN '美国'
            WHEN country = 'JP' THEN '日本'
            WHEN country = 'KR' THEN '韩国'
            WHEN country = 'BR' THEN '巴西'
            WHEN country = 'DE' THEN '德国'
            WHEN country = 'CA' THEN '加拿大'
            WHEN country = 'MX' THEN '墨西哥'
            WHEN country = 'GB' THEN '英国'
            WHEN country = 'AU' THEN '澳大利亚' 
            WHEN country = 'FR' THEN '法国' 
            WHEN country = 'RU' THEN '俄罗斯'
            -- 东南亚国家单独列出 
            WHEN country IN ('SG', 'MY', 'TH', 'VN', 'ID', 'PH', 'LA', 'MM', 'KH', 'BN') THEN '东南亚' 
            -- 其他亚洲国家 
            WHEN country IN ('CN', 'HK', 'TW', 'IN', 'PK', 'BD', 'NP', 'LK', 'IR', 'IQ', 'JO', 'SY', 'LB', 'PS', 'AE', 'QA', 'OM', 'SA', 'YE') THEN '亚洲' 
            WHEN country IN ('IT', 'ES', 'PT', 'BE', 'NL', 'SE', 'NO', 'FI', 'DK', 'AT', 'CH', 'PL', 'CZ', 'HU', 'RO', 'GR', 'TR') THEN '欧洲' 
            WHEN country IN ('AR', 'CO', 'PE', 'VE', 'BO', 'CL', 'PY', 'UY', 'EC', 'SR', 'GT', 'SV', 'HN', 'NI', 'CR', 'PA', 'JM', 'CU', 'DO', 'HT', 'PR', 'JM') THEN '拉丁美洲' 
            WHEN country IN ('ZA', 'NG', 'KE', 'EG', 'SA', 'MA', 'TZ', 'UG', 'CD', 'ZA', 'SN', 'GH', 'TG', 'CI', 'MZ', 'ZW', 'AO', 'ML', 'NE', 'TD', 'SD', 'SO', 'ET', 'KE', 'UG', 'TZ', 'RW', 'BI', 'CD', 'CG', 'CM', 'GQ', 'ST', 'GN', 'LR', 'SL', 'GM', 'NA', 'BW', 'LS', 'MZ', 'ZW', 'ZM') THEN '非洲' 
            WHEN country IN ('NZ', 'FJ', 'PG', 'KI', 'TO', 'SB', 'VU', 'NR', 'WS', 'NC', 'PF', 'NU', 'TK', 'FM', 'MH', 'GU', 'MP', 'AS', 'UM') THEN '大洋洲' 
            ELSE '其他' 
        END AS country_region, 
    count(load_start.attempt_id) as cnt_load_start,
    count(load_end.attempt_id) as cnt_load_success,
    count(distinct load_start.bundle_id) as cnt_uid,
    sum(rvn)  as rvn

from load_start
left join load_end
on load_start.dt = load_end.dt
and load_start.bundle_id = load_end.bundle_id
and load_start.unit = load_end.unit
and load_start.attempt_id = load_end.attempt_id

group by load_start.dt,
    -- load_start.bundle_id,
    load_start.unit,
    load_start.event_name,
    CASE                                                         
            WHEN country = 'US' THEN '美国'
            WHEN country = 'JP' THEN '日本'
            WHEN country = 'KR' THEN '韩国'
            WHEN country = 'BR' THEN '巴西'
            WHEN country = 'DE' THEN '德国'
            WHEN country = 'CA' THEN '加拿大'
            WHEN country = 'MX' THEN '墨西哥'
            WHEN country = 'GB' THEN '英国'
            WHEN country = 'AU' THEN '澳大利亚' 
            WHEN country = 'FR' THEN '法国' 
            WHEN country = 'RU' THEN '俄罗斯'
            -- 东南亚国家单独列出 
            WHEN country IN ('SG', 'MY', 'TH', 'VN', 'ID', 'PH', 'LA', 'MM', 'KH', 'BN') THEN '东南亚' 
            -- 其他亚洲国家 
            WHEN country IN ('CN', 'HK', 'TW', 'IN', 'PK', 'BD', 'NP', 'LK', 'IR', 'IQ', 'JO', 'SY', 'LB', 'PS', 'AE', 'QA', 'OM', 'SA', 'YE') THEN '亚洲' 
            WHEN country IN ('IT', 'ES', 'PT', 'BE', 'NL', 'SE', 'NO', 'FI', 'DK', 'AT', 'CH', 'PL', 'CZ', 'HU', 'RO', 'GR', 'TR') THEN '欧洲' 
            WHEN country IN ('AR', 'CO', 'PE', 'VE', 'BO', 'CL', 'PY', 'UY', 'EC', 'SR', 'GT', 'SV', 'HN', 'NI', 'CR', 'PA', 'JM', 'CU', 'DO', 'HT', 'PR', 'JM') THEN '拉丁美洲' 
            WHEN country IN ('ZA', 'NG', 'KE', 'EG', 'SA', 'MA', 'TZ', 'UG', 'CD', 'ZA', 'SN', 'GH', 'TG', 'CI', 'MZ', 'ZW', 'AO', 'ML', 'NE', 'TD', 'SD', 'SO', 'ET', 'KE', 'UG', 'TZ', 'RW', 'BI', 'CD', 'CG', 'CM', 'GQ', 'ST', 'GN', 'LR', 'SL', 'GM', 'NA', 'BW', 'LS', 'MZ', 'ZW', 'ZM') THEN '非洲' 
            WHEN country IN ('NZ', 'FJ', 'PG', 'KI', 'TO', 'SB', 'VU', 'NR', 'WS', 'NC', 'PF', 'NU', 'TK', 'FM', 'MH', 'GU', 'MP', 'AS', 'UM') THEN '大洋洲' 
            ELSE '其他' 
        END
;

------------------------新增用户

                SELECT
                    dt,
                    CASE                                                         
                        WHEN country = 'US' THEN '美国'
                        WHEN country = 'JP' THEN '日本'
                        WHEN country = 'KR' THEN '韩国'
                        WHEN country = 'BR' THEN '巴西'
                        WHEN country = 'DE' THEN '德国'
                        WHEN country = 'CA' THEN '加拿大'
                        WHEN country = 'MX' THEN '墨西哥'
                        WHEN country = 'GB' THEN '英国'
                        WHEN country = 'AU' THEN '澳大利亚' 
                        WHEN country = 'FR' THEN '法国' 
                        WHEN country = 'RU' THEN '俄罗斯'
                        -- 东南亚国家单独列出 
                        WHEN country IN ('SG', 'MY', 'TH', 'VN', 'ID', 'PH', 'LA', 'MM', 'KH', 'BN') THEN '东南亚' 
                        -- 其他亚洲国家 
                        WHEN country IN ('CN', 'HK', 'TW', 'IN', 'PK', 'BD', 'NP', 'LK', 'IR', 'IQ', 'JO', 'SY', 'LB', 'PS', 'AE', 'QA', 'OM', 'SA', 'YE') THEN '亚洲' 
                        WHEN country IN ('IT', 'ES', 'PT', 'BE', 'NL', 'SE', 'NO', 'FI', 'DK', 'AT', 'CH', 'PL', 'CZ', 'HU', 'RO', 'GR', 'TR') THEN '欧洲' 
                        WHEN country IN ('AR', 'CO', 'PE', 'VE', 'BO', 'CL', 'PY', 'UY', 'EC', 'SR', 'GT', 'SV', 'HN', 'NI', 'CR', 'PA', 'JM', 'CU', 'DO', 'HT', 'PR', 'JM') THEN '拉丁美洲' 
                        WHEN country IN ('ZA', 'NG', 'KE', 'EG', 'SA', 'MA', 'TZ', 'UG', 'CD', 'ZA', 'SN', 'GH', 'TG', 'CI', 'MZ', 'ZW', 'AO', 'ML', 'NE', 'TD', 'SD', 'SO', 'ET', 'KE', 'UG', 'TZ', 'RW', 'BI', 'CD', 'CG', 'CM', 'GQ', 'ST', 'GN', 'LR', 'SL', 'GM', 'NA', 'BW', 'LS', 'MZ', 'ZW', 'ZM') THEN '非洲' 
                        WHEN country IN ('NZ', 'FJ', 'PG', 'KI', 'TO', 'SB', 'VU', 'NR', 'WS', 'NC', 'PF', 'NU', 'TK', 'FM', 'MH', 'GU', 'MP', 'AS', 'UM') THEN '大洋洲' 
                        ELSE '其他' 
                    END AS country_region,
                    json_extract_scalar(params, '$.media_source') as media_source, --可能重复
                    count(distinct bundle_id)  as cnt_uid

                    

               FROM pub_1805.arrowpuzzle_android_signup 
               WHERE dt >= '2026-07-03'
               group by dt,
                    CASE                                                         
                        WHEN country = 'US' THEN '美国'
                        WHEN country = 'JP' THEN '日本'
                        WHEN country = 'KR' THEN '韩国'
                        WHEN country = 'BR' THEN '巴西'
                        WHEN country = 'DE' THEN '德国'
                        WHEN country = 'CA' THEN '加拿大'
                        WHEN country = 'MX' THEN '墨西哥'
                        WHEN country = 'GB' THEN '英国'
                        WHEN country = 'AU' THEN '澳大利亚' 
                        WHEN country = 'FR' THEN '法国' 
                        WHEN country = 'RU' THEN '俄罗斯'
                        -- 东南亚国家单独列出 
                        WHEN country IN ('SG', 'MY', 'TH', 'VN', 'ID', 'PH', 'LA', 'MM', 'KH', 'BN') THEN '东南亚' 
                        -- 其他亚洲国家 
                        WHEN country IN ('CN', 'HK', 'TW', 'IN', 'PK', 'BD', 'NP', 'LK', 'IR', 'IQ', 'JO', 'SY', 'LB', 'PS', 'AE', 'QA', 'OM', 'SA', 'YE') THEN '亚洲' 
                        WHEN country IN ('IT', 'ES', 'PT', 'BE', 'NL', 'SE', 'NO', 'FI', 'DK', 'AT', 'CH', 'PL', 'CZ', 'HU', 'RO', 'GR', 'TR') THEN '欧洲' 
                        WHEN country IN ('AR', 'CO', 'PE', 'VE', 'BO', 'CL', 'PY', 'UY', 'EC', 'SR', 'GT', 'SV', 'HN', 'NI', 'CR', 'PA', 'JM', 'CU', 'DO', 'HT', 'PR', 'JM') THEN '拉丁美洲' 
                        WHEN country IN ('ZA', 'NG', 'KE', 'EG', 'SA', 'MA', 'TZ', 'UG', 'CD', 'ZA', 'SN', 'GH', 'TG', 'CI', 'MZ', 'ZW', 'AO', 'ML', 'NE', 'TD', 'SD', 'SO', 'ET', 'KE', 'UG', 'TZ', 'RW', 'BI', 'CD', 'CG', 'CM', 'GQ', 'ST', 'GN', 'LR', 'SL', 'GM', 'NA', 'BW', 'LS', 'MZ', 'ZW', 'ZM') THEN '非洲' 
                        WHEN country IN ('NZ', 'FJ', 'PG', 'KI', 'TO', 'SB', 'VU', 'NR', 'WS', 'NC', 'PF', 'NU', 'TK', 'FM', 'MH', 'GU', 'MP', 'AS', 'UM') THEN '大洋洲' 
                        ELSE '其他' 
                    END ,
                    json_extract_scalar(params, '$.media_source') 
;




------------------留存

WITH base_install AS (
    SELECT
        dt AS install_dt,
        bundle_id AS user_id
    FROM pub_1805.arrowpuzzle_android_signup 
    WHERE dt >= '2026-07-03'
    GROUP BY dt, bundle_id
),
base_active AS (
    SELECT
        dt AS active_dt,
        bundle_id AS user_id
    FROM pub_1805.arrowpuzzle_android
    WHERE dt >= '2026-07-03'
      AND event_name = 'APLS'
    GROUP BY dt, bundle_id
)
SELECT
    i.install_dt,
    COUNT(DISTINCT i.user_id) AS install_user_cnt,
    -- 次日留存
    COUNT(DISTINCT CASE 
        WHEN date_diff('day', date_parse(i.install_dt, '%Y-%m-%d'), date_parse(a.active_dt, '%Y-%m-%d')) = 1 
        THEN a.user_id 
    END) AS retain_1d_user

    -- -- 3日留存
    -- COUNT(DISTINCT CASE 
    --     WHEN date_diff('day', date_parse(i.install_dt, '%Y-%m-%d'), date_parse(a.active_dt, '%Y-%m-%d')) = 3 
    --     THEN a.user_id 
    -- END) AS retain_3d_user,

    -- ROUND(
    --     COUNT(DISTINCT CASE 
    --         WHEN date_diff('day', date_parse(i.install_dt, '%Y-%m-%d'), date_parse(a.active_dt, '%Y-%m-%d')) = 3 
    --         THEN a.user_id 
    --     END) 
    --     / CAST(COUNT(DISTINCT i.user_id) AS DOUBLE),
    -- 4
    -- ) AS retain_3d_rate

FROM base_install i
LEFT JOIN base_active a
    ON i.user_id = a.user_id

GROUP BY i.install_dt
;




with base_info as 
(
    SELECT
        dt,
        bundle_id, 
        count(1)  as cnt_uid

    FROM pub_1805.arrowpuzzle_android_signup 
    WHERE dt >= '2026-07-03'
    group by dt,
        bundle_id
)
select 
dt ,
bundle_id
from base_info
where cnt_uid > 1
;