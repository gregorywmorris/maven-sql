-- Analyzing Website Performance

-- Session type by week
SELECT
  MIN(DATE(created_at)) AS sessions_date,
  COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
  COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM
  website_sessions
WHERE
  created_at < '2012-06-09'
GROUP BY
  YEAR(created_at),
  WEEK(created_at);

-- Landing page count
DROP TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview AS
SELECT
  website_session_id,
  MIN(website_pageview_id) AS min_pv_id
FROM
  website_pageviews
WHERE
  website_pageview_id < 1000
GROUP BY
  website_session_id;

SELECT
  website_pageviews.pageview_url AS landing_page,
  count(first_pageview.website_session_id) landing_count
FROM
  first_pageview
LEFT JOIN
  website_pageviews
ON
  first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY
  landing_page;

-- Page view count
SELECT
  pageview_url,
  COUNT(pageview_url) AS sessions
FROM
  website_pageviews
WHERE
  created_at < '2012-06-09'
GROUP BY
  pageview_url;

-- Top entry page
DROP TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview AS
SELECT
  website_session_id,
  MIN(website_pageview_id) AS min_pv_id
FROM
  website_pageviews
GROUP BY
  website_session_id;

SELECT
  website_pageviews.pageview_url AS landing_page,
  COUNT(first_pageview.website_session_id) AS sessions_hitting_this_landing_page
FROM
  first_pageview
LEFT JOIN
  website_pageviews
ON
  first_pageview.min_pv_id = website_pageviews.website_pageview_id
WHERE
  website_pageviews.created_at < '2012-06-12'
GROUP BY
  landing_page;

--