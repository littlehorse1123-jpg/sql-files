select 
bundleid,
count(distinct user_type) as cnt_type

from dws_1805.dws_android_abtest_ads_stat_day
where dt = '2026-07-09'
and experimentid = 'AdAggPlan_Arrow013V114'
group by bundleid 
;





select 
        dt,
        usertype,
        registdate,
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
        experimentgroup,
        experimentgroupvalue,
        sum(try_cast(activeusercount as double)) as activeusercount,
        sum(try_cast(bannercount as double)) as bannercount,
        sum(try_cast(fullscreencount as double)) as  fullscreencount,
        sum(try_cast(rewardedvideocount as double)) as rewardvideocount,
        sum(try_cast(bannerpv as double)) as bannerpv,
        sum(try_cast(fullscreenpv as double)) as interpv,
        sum(try_cast(rewardedvideopv as double)) as rewardvideopv

from pub_1805.dws_android_abtest_ads_stat_day
where dt >= '2026-06-21'
and dt <= '2026-07-04'
and experimentid LIKE '%AdAggPlan_Arrow013V114%'
and experimentgroup = '2' ---服务端
group by 
        dt,
        usertype,
        registdate,
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
        experimentgroup,
        experimentgroupvalue