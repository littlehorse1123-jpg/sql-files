 SELECT 
    dt,
    substr(base_time, 1, 10) AS base_time,
    substr(install_time, 1, 10) AS install_date,
    
    -- 带正负的天数差（base_time - install_date）
    date_diff(
        'day',
        -- 为空时返回 null，不报错
        try(date_parse(substr(install_time, 1, 10), '%Y-%m-%d')),
        try(date_parse(substr(base_time, 1, 10), '%Y-%m-%d'))
    ) AS day_diff_with_sign,
    json_extract_scalar(params, '$.msg') as msg,
    json_extract_scalar(json_extract(params, '$.msg'),'$.adFormat') as adFormat,
    json_extract_scalar(json_extract_scalar(params, '$.msg'),'$.revenue') AS msg,
    
   -- 提取 adFormat
    regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([A-Z_]+)', 1) AS adFormat,

    -- 转成数字类型
    try_cast(regexp_extract(json_extract_scalar(params, '$.msg'), 'revenue:\s*([0-9.E+-]+)', 1) AS double) AS revenue
    

FROM pub_1701.watersort_ios
WHERE dt = '2026-05-26'
  AND event_name = 'SBBQ'  
LIMIT 100;
-------------------------------------------------------



SELECT 
    dt,
    substr(base_time, 1, 10) AS base_time,
    substr(install_time, 1, 10) AS install_date,
    
    -- 带正负的天数差（base_time - install_date）
    date_diff(
        'day',
        -- 为空时返回 null，不报错
        try(date_parse(substr(install_time, 1, 10), '%Y-%m-%d')),
        try(date_parse(substr(base_time, 1, 10), '%Y-%m-%d'))
    ) AS day_diff_with_sign,
    json_extract_scalar(params, '$.msg') as msg,
    json_extract_scalar(json_extract(params, '$.msg'),'$.adFormat') as adFormat,
    json_extract_scalar(json_extract_scalar(params, '$.msg'),'$.revenue') AS msg,
    
   -- 提取 adFormat
    regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([A-Z_]+)', 1) AS adFormat,

    -- 转成数字类型
    try_cast(regexp_extract(json_extract_scalar(params, '$.msg'), 'revenue:\s*([0-9.E+-]+)', 1) AS double) AS revenue
    

FROM pub_1701.watersort_ios
WHERE dt = '2026-05-26'
  AND event_name = 'SBBQ'  
LIMIT 100;


-- -----------------------------------------------按照day_diff_with_sign计算0-7天、7-31天、31+天的分组统计
WITH raw_data AS (
    SELECT 
        dt,
        substr(base_time, 1, 10) AS base_time,
        substr(install_time, 1, 10) AS install_date,
        
        -- 带正负的天数差（base_time - install_date）
        date_diff(
            'day',
            -- 为空时返回 null，不报错
            try(date_parse(substr(install_time, 1, 10), '%Y-%m-%d')),
            try(date_parse(substr(base_time, 1, 10), '%Y-%m-%d'))
        ) AS day_diff_with_sign,
        
        -- 提取 adFormat
        regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([A-Z_]+)', 1) AS adFormat,

        -- 转成数字类型
        try_cast(regexp_extract(json_extract_scalar(params, '$.msg'), 'revenue:\s*([0-9.E+-]+)', 1) AS double) AS revenue
        

    FROM pub_1701.watersort_ios
    WHERE dt >= '2026-06-01'
      AND event_name = 'SBBQ'
      AND regexp_extract(json_extract_scalar(params, '$.msg'), 'adFormat:\s*([A-Z_]+)', 1) IS NOT NULL
      AND try_cast(regexp_extract(json_extract_scalar(params, '$.msg'), 'revenue:\s*([0-9.E+-]+)', 1) AS double) IS NOT NULL
),
grouped_data AS (

    SELECT dt, 
        CASE day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        adFormat,
        revenue,
        1 AS pv  -- 每条记录代表一次展示(pv)
    FROM raw_data
    WHERE day_diff_with_sign IS NOT NULL

)
SELECT
    dt,
    date_range,
    adFormat,
    COUNT(pv) AS pv,
    SUM(revenue) AS revenue

FROM grouped_data
GROUP BY dt,date_range, adFormat
;

-- ORDER BY dt, date_range, adFormat;



---------------bobodu水排序安卓查收入，ULP

with base_info as
(
    select 

    dt,
    bundle_id,
    try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
    -- substr(base_time, 1, 10) AS base_time,
    --     substr(install_time, 1, 10) AS install_date,
        
    --     -- 带正负的天数差（base_time - install_date）
    --     date_diff(
    --         'day',
    --         -- 为空时返回 null，不报错
    --         try(date_parse(substr(install_time, 1, 10), '%Y-%m-%d')),
    --         try(date_parse(substr(base_time, 1, 10), '%Y-%m-%d'))
    --     ) AS day_diff_with_sign,
    json_extract_scalar(params, '$.msg') AS msg

    from pub_1701.watersort_android 
        WHERE dt >= '2026-06-01'
        AND event_name = 'SBBQ'

),
cal_step2 as 
(
        select 

                dt,
                bundle_id,
                day_diff_with_sign,
                COALESCE(
                    regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
                    regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
                ) AS adFormat,
                COALESCE(
                    regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
                    regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
                ) AS networkName,
                TRY_CAST(
                    REPLACE(
                        REPLACE(
                                    regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1),
                            '/', '.'
                        ),
                        ',', '.'
                    ) AS DOUBLE
                ) AS revenue

        from base_info  
)
select 

        dt,
        adFormat,
        networkName,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        sum(revenue) as revenue,
        count(1) as cnt

from cal_step2 
group by dt, adFormat, networkName,CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END

;


----------------------------------------------------------------------------------



with base_info as
(
    select 

    dt,
    bundle_id,
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
    try_cast(installed_seconds as bigint)/86400 AS day_diff_with_sign,
    -- substr(base_time, 1, 10) AS base_time,
    --     substr(install_time, 1, 10) AS install_date,
        
    --     -- 带正负的天数差（base_time - install_date）
    --     date_diff(
    --         'day',
    --         -- 为空时返回 null，不报错
    --         try(date_parse(substr(install_time, 1, 10), '%Y-%m-%d')),
    --         try(date_parse(substr(base_time, 1, 10), '%Y-%m-%d'))
    --     ) AS day_diff_with_sign,
    json_extract_scalar(params, '$.msg') AS msg

    from pub_1701.watersort_android 
        WHERE 1=1
        and dt in ('2026-06-22', '2026-06-29')
        -- and dt <= '2026-06-24'
        AND event_name = 'SBBQ'

),
cal_step2 as 
(
        select 

                dt,
                bundle_id,
                country_region,
                day_diff_with_sign,
                COALESCE(
                    regexp_extract(msg, 'adFormat=''([^'']*)''', 1),
                    regexp_extract(msg, 'adFormat:\s*([^,\]]+)', 1)
                ) AS adFormat,
                COALESCE(
                    regexp_extract(msg, 'adNetwork=''([^'']*)''', 1),
                    regexp_extract(msg, 'networkName:\s*([^,\]]+)', 1)
                ) AS networkName,
                TRY_CAST(
                    REPLACE(
                        REPLACE(
                                    regexp_extract(msg, 'revenue=([^,]+),\s*precision', 1),
                            '/', '.'
                        ),
                        ',', '.'
                    ) AS DOUBLE
                ) AS revenue

        from base_info  
)
select 

        dt,
        adFormat,
        networkName,
        country_region,
        CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END AS date_range,
        sum(revenue) as revenue,
        count(1) as cnt

from cal_step2 
group by dt, adFormat, country_region, networkName,CASE when day_diff_with_sign <0 then '<0天'
            WHEN day_diff_with_sign >= 0 AND day_diff_with_sign <= 7 THEN '0-7天'
            WHEN day_diff_with_sign > 7 AND day_diff_with_sign <= 31 THEN '7-31天'
            WHEN day_diff_with_sign > 31 THEN '31+天'
            ELSE '未知'
        END

;