-- Analyzing Traffic Sources

--conversion rate
SELECT
  website_sessions.utm_content,
  COUNT(DISTINCT website_sessions.website_session_id) AS session,
  COUNT(DISTINCT orders.order_id) AS orders,
  COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS sessions_to_order_conv_rt
FROM
  website_sessions
LEFT JOIN
  orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
  website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY
  website_sessions.utm_content
ORDER BY
  COUNT(DISTINCT website_sessions.website_session_id) DESC;

-- site traffic breakdown
SELECT
  utm_source,
  utm_campaign,
  http_referer,
  COUNT(DISTINCT website_sessions.website_session_id) AS session
FROM
  website_sessions
WHERE
  website_sessions.created_at < '2012-04-12'
GROUP BY
  utm_source, utm_campaign, http_referer
ORDER BY
  session DESC;

-- campaign cvr
SELECT
  COUNT(DISTINCT website_sessions.website_session_id) AS session,
  COUNT(DISTINCT orders.order_id) AS orders,
  COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS sessions_to_order_conv_rt
FROM
  website_sessions
LEFT JOIN
  orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
  website_sessions.created_at < '2012-04-14'
  AND website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
  session DESC;

-- pivot table
SELECT
  primary_product_id,
  COUNT(CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_items,
  COUNT(CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_items,
  COUNT(order_id) AS total_orders
FROM
  orders
GROUP BY
  primary_product_id;

-- sessions by week gsearch volume trends
SELECT
  MIN(DATE(created_at)) AS sessions_date,
  COUNT(website_session_id) AS sessions_count
FROM
  website_sessions
WHERE
  created_at < '2012-05-10'
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
GROUP BY
  YEAR(created_at), 
  WEEK(created_at);

-- device level performance
SELECT
  website_sessions.device_type,
  COUNT(website_sessions.website_session_id) AS sessions,
  COUNT(orders.order_id) AS orders,
  COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS sessions_to_order_conv_rt
FROM
  website_sessions
LEFT JOIN
  orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
  website_sessions.created_at < '2012-05-11'
GROUP BY
  website_sessions.device_type;

-- device level weekly trends

SELECT
  MIN(DATE(created_at)) AS sessions_date,
  COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
  COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM
  website_sessions
WHERE
  created_at between '2012-04-15' and '2012-06-09'
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
GROUP BY
  YEAR(created_at),
  WEEK(created_at);
