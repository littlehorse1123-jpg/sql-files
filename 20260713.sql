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
    END) AS retain_1d_user


FROM base_install i
LEFT JOIN base_active a
    ON i.user_id = a.user_id

GROUP BY i.install_dt
;
