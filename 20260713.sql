----DAU
WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign 

               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-01' 
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

    from raw

    group by dt,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END 
;


----DAU
WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  country 

               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-01' 
               AND event_name = 'APLS' 
    )

    select 
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
        count(distinct bundle_id)

    from raw

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
                END 
;

-----------留存
WITH base_install AS (
    SELECT
        dt AS install_dt,
        bundle_id AS user_id
    FROM pub_1805.ballsort_android_signup 
    WHERE dt >= '2026-06-01'
    GROUP BY dt, bundle_id
),
base_active AS (
    SELECT
        dt AS active_dt,
        bundle_id AS user_id
    FROM pub_1805.ballsort_android
    WHERE dt >= '2026-06-01'
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
    END) AS retain_1d_user,
    COUNT(DISTINCT CASE 
        WHEN date_diff('day', date_parse(i.install_dt, '%Y-%m-%d'), date_parse(a.active_dt, '%Y-%m-%d')) = 7 
        THEN a.user_id 
    END) AS retain_1d_user


FROM base_install i
LEFT JOIN base_active a
    ON i.user_id = a.user_id

GROUP BY i.install_dt
;


---------------------------------------按生命周期---------------------------------


WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  event_name,
                  max(try_cast(installed_seconds as bigint)/86400) AS day_diff_with_sign,
                  count(1) as pv

               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-05' 
               AND event_name in ('VVS','IIS') 
               group by dt, event_name, bundle_id
    )

    select 
        dt,
        event_name,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        count(distinct bundle_id),
        sum(pv) as pv

    from raw

    group by dt,event_name,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END 
;


---------------------------------------按国家--------------------------------
WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  event_name,
                  max(country) AS country,
                  count(1) as pv

               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-05' 
               AND event_name in ('VVS','IIS') 
               group by dt, event_name, bundle_id
    )

    select 
        dt,
        event_name,
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
        count(distinct bundle_id),
        sum(pv) as pv

    from raw

    group by dt,event_name,
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

--------------------------------

                SELECT
                  dt,   
                  json_extract_scalar(params, '$.msg') AS msg, 
                  try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
                  json_extract_scalar(params, '$.mdi') AS mdi,
                  try_cast(json_extract_scalar(params, '$.def') as double) AS revenue   

               FROM pub_1805.ballsort_android
               WHERE dt >= '2026-06-05' 
            --    AND event_name = 'IPD' 
                and json_extract_scalar(params, '$.def') is not null


------------------------------------------


WITH raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  event_name,
                  country,
                  COALESCE(
                     regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat=''([^'']*)''', 1),
                     regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([^,\]]+)', 1)
                  ) AS adFormat,
                  try_cast(json_extract_scalar(params, '$.def') as double) AS revenue  


               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-05' 
               AND event_name in ('IPD') 

    )

    select 
        dt,
        event_name,
        adFormat,
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
        count(distinct bundle_id) as cnt_uid,
        sum(revenue) as revenue,
        count(1) as pv

    from raw

    group by dt,
        event_name,
        adFormat,
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


with base_dau_info as 
(

             SELECT
                  dt,   
                  bundle_id, 
                  country 

               FROM pub_1805.ballsort_android 
               WHERE dt >= '2026-06-05' 
               and dt <= '2026-06-19'
               AND event_name = 'APLS' 
               and country = 'US'
               group by dt, bundle_id, country

),
raw AS (  
                SELECT
                  dt,   
                  bundle_id, 
                  event_name,
                  country as ipd_country,
                  COALESCE(
                     regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat=''([^'']*)''', 1),
                     regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([^,\]]+)', 1)
                  ) AS adFormat,
                  try_cast(json_extract_scalar(params, '$.def') as double) AS revenue  


               FROM pub_1805.ballsort_android 
                WHERE dt >= '2026-06-05' 
               and dt <= '2026-06-19'
               AND event_name in ('IPD') 

),
cal_step1 as 
(
    select dt,
           bundle_id,
           adFormat,
           ipd_country,
           sum(revenue) as revenue
    from step1
    where adFormat in  ('banner','interstitial', 'rewarded_video')
    group by dt,
           bundle_id,
           ipd_country,
           adFormat
)
select dt,
       adFormat,
       ipd_country,
       count(distinct b.bundle_id) as cnt_dau_with_revenue,
       sum(revenue) as revenue

from base_dau_info as a
left join cal_step1 as b
on a.dt = b.dt
and a.bundle_id = b.bundle_id

group by dt,
       adFormat,
       ipd_country

;




--87f1bbb4f4e74806b19a8a170841b72d
             SELECT
                  *

               FROM pub_1805.ballsort_android 
               WHERE dt = '2026-06-25' 
                AND bundle_id = '87f1bbb4f4e74806b19a8a170841b72d'
;

--------------------------------------------关卡结束
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
                  case when  try_cast(card_game_id as double) is null then 'null'
                       when try_cast(card_game_id as double) <=10 then card_game_id 
                       when try_cast(card_game_id as double) >10 then '>10'
                       else 'Other' end as card_game_id,
                  CASE  when try_cast(installed_seconds as bigint)/86400 <0 then '<0天'
                        WHEN try_cast(installed_seconds as bigint)/86400 >= 0 AND try_cast(installed_seconds as bigint)/86400 <= 7 THEN '0-7天'
                        WHEN try_cast(installed_seconds as bigint)/86400 > 7 AND try_cast(installed_seconds as bigint)/86400 <= 31 THEN '7-31天'
                        WHEN try_cast(installed_seconds as bigint)/86400 > 31 THEN '31+天'
                        ELSE '未知'
                    END AS date_range,
                  card_game_type,
                  result,
                  end_reason,
                  count(1) as pv
                  

               FROM pub_1805.ballsort_android a
               WHERE dt >= '2026-06-17' 
                and dt <= '2026-06-30'
                and event_name in ('L_W','L_F')--,'IIS','VVS','IWB','IBW','IBR')
                -- and country = 'US'


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
                  case when  try_cast(card_game_id as double) is null then 'null'
                       when try_cast(card_game_id as double) <=10 then card_game_id 
                       when try_cast(card_game_id as double) >10 then '>10'
                       else 'Other' end ,
                  CASE  when try_cast(installed_seconds as bigint)/86400 <0 then '<0天'
                        WHEN try_cast(installed_seconds as bigint)/86400 >= 0 AND try_cast(installed_seconds as bigint)/86400 <= 7 THEN '0-7天'
                        WHEN try_cast(installed_seconds as bigint)/86400 > 7 AND try_cast(installed_seconds as bigint)/86400 <= 31 THEN '7-31天'
                        WHEN try_cast(installed_seconds as bigint)/86400 > 31 THEN '31+天'
                        ELSE '未知'
                    END,
                  card_game_type,
                  result,
                  end_reason
    ;


--------------------------------------

             SELECT
                  dt,
                  count(1) as cnt

               FROM pub_1805.ballsort_android 
               WHERE dt = '2026-06-25' 
                and event_name in ('IPD')
                and country = 'IR'
                group by dt




--------------------------------------
             SELECT
                  dt,
                  card_game_type,
                  result,
                  end_reason,
                  case when  try_cast(card_game_id as double) is null then 'null'
                       when try_cast(card_game_id as double) <=10 then card_game_id 
                       when try_cast(card_game_id as double) >10 then '>10'
                       else 'Other' end as card_game_id,
                  json_extract_scalar(params, '$.pos') as pos,
                  count(1) as pv
                  

               FROM pub_1805.ballsort_android a
               WHERE dt >= '2026-06-17' 
                and dt <= '2026-06-30'
                and event_name in ('IIS')--,'IIS','VVS','IWB','IBW','IBR')
                -- and country = 'US'

              group by dt,
                  card_game_type,
                  result,
                  end_reason,
                  case when  try_cast(card_game_id as double) is null then 'null'
                       when try_cast(card_game_id as double) <=10 then card_game_id 
                       when try_cast(card_game_id as double) >10 then '>10'
                       else 'Other' end 
                  json_extract_scalar(params, '$.pos')
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
        CASE 
            WHEN day_diff_with_sign < 0 THEN '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 1 THEN '0-1天'
            WHEN day_diff_with_sign > 1 AND day_diff_with_sign <= 7 THEN '1-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        count(distinct bundle_id)

    from cleaned

    group by dt,
        CASE 
            WHEN day_diff_with_sign < 0 THEN '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 1 THEN '0-1天'
            WHEN day_diff_with_sign > 1 AND day_diff_with_sign <= 7 THEN '1-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END 
;



SELECT
    dt,
    country_region,
    card_game_id,
    card_game_type,
    result,
    end_reason,
    CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
    count(1) as pv

FROM (
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
        case when  try_cast(card_game_id as double) is null then 'null'
             when try_cast(card_game_id as double) <=10 then card_game_id 
             when try_cast(card_game_id as double) >10 then '>10'
             else 'Other' end as card_game_id,
        card_game_type,
        result,
        end_reason,
        try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
        ROW_NUMBER() OVER (
            PARTITION BY dt, bundle_id -- 需要替换为实际的用户ID列名
            ORDER BY time DESC  -- 需要替换为实际的时间戳列名
        ) as rn

    FROM pub_1805.ballsort_android a
    WHERE dt >= '2026-06-17' 
        and dt <= '2026-06-30'
        and event_name in ('L_W','L_F')--,'IIS','VVS','IWB','IBW','IBR')
        -- and country = 'US'
) ranked_data
WHERE rn = 1  -- 只取每个分组的第一条记录（即最新记录）

group  by dt,
    country_region,
    card_game_id,
    card_game_type,
    result,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END,
    end_reason
;




SELECT
    dt,
    country_region,
    card_game_id,
    card_game_type,
    result,
    end_reason,
    CASE 
        WHEN day_diff_with_sign < 0 THEN '<0天'
        WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 1 THEN '0-1天'
        WHEN day_diff_with_sign > 1 AND day_diff_with_sign <= 7 THEN '1-7天'
        WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
        WHEN day_diff_with_sign > 31 THEN '31+天'
        ELSE '未知'
    END AS date_range,
    count(1) as pv

FROM (
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
        case when  try_cast(card_game_id as double) is null then 'null'
             when try_cast(card_game_id as double) <=10 then card_game_id 
             when try_cast(card_game_id as double) >10 then '>10'
             else 'Other' end as card_game_id,
        card_game_type,
        result,
        end_reason,
        try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
        ROW_NUMBER() OVER (
            PARTITION BY dt, bundle_id
            ORDER BY time DESC
        ) as rn

    FROM pub_1805.ballsort_android a
    WHERE dt >= '2026-06-17' 
        and dt <= '2026-06-30'
        and event_name in ('L_W','L_F')--,'IIS','VVS','IWB','IBW','IBR')
        -- and country = 'US'
) ranked_data
WHERE rn = 1  -- 只取每个分组的第一条记录（即最新记录）

GROUP BY dt,
    country_region,
    card_game_id,
    card_game_type,
    result,
    CASE 
        WHEN day_diff_with_sign < 0 THEN '<0天'
        WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 1 THEN '0-1天'
        WHEN day_diff_with_sign > 1 AND day_diff_with_sign <= 7 THEN '1-7天'
        WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
        WHEN day_diff_with_sign > 31 THEN '31+天'
        ELSE '未知'
    END,
    end_reason

;



----------------------------------------------------------新增用户的国家分布---------------------------------------


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
                    count(distinct bundle_id)  as cnt_uid

                    

               FROM pub_1805.ballsort_android_signup 
               WHERE dt >= '2026-06-01' 
                and dt <= '2026-06-16'
                -- and country IN ('CN', 'HK', 'TW', 'IN', 'PK', 'BD', 'NP', 'LK', 'IR', 'IQ', 'JO', 'SY', 'LB', 'PS', 'AE', 'QA', 'OM', 'SA', 'YE') 
                
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
        END
;


-------------------------------------------美国用户--------------------------------------