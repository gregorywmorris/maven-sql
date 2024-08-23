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

-- Identify landing page bounce rate - overbuilt??
DROP TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview AS
SELECT
  website_pageviews.website_session_id,
  MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM
  website_pageviews
  INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
  website_pageviews.website_session_id;

DROP TABLE IF EXISTS sessions_w_landing_page
CREATE TEMPORARY TABLE sessions_w_landing_page AS
SELECT
  first_pageview.website_session_id,
  website_pageviews.pageview_url AS landing_page
FROM
  first_pageview
LEFT JOIN
  website_pageviews
ON
  website_pageviews.website_pageview_id = first_pageview.min_pv_id;

DROP TABLE IF EXISTS bounced_sessions_only
CREATE TEMPORARY TABLE bounced_sessions_only AS
SELECT
  sessions_w_landing_page.website_session_id,
  sessions_w_landing_page.landing_page,
  COUNT(website_pageviews.website_pageview_id) AS count_of_pageviews
FROM
  sessions_w_landing_page
LEFT JOIN
  website_pageviews ON website_pageviews.website_session_id = sessions_w_landing_page.website_session_id
GROUP BY
  sessions_w_landing_page.website_session_id,
  sessions_w_landing_page.landing_page
HAVING
  count(website_pageviews.website_pageview_id) = 1;

SELECT
  sessions_w_landing_page.landing_page,
  COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions,
  COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
  COUNT(DISTINCT bounced_sessions_only.website_session_id) / COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
FROM
  sessions_w_landing_page
LEFT JOIN bounced_sessions_only
  ON sessions_w_landing_page.website_session_id =  bounced_sessions_only.website_session_id
GROUP BY
  sessions_w_landing_page.landing_page;

-- homepage bounce rate
DROP TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview AS
SELECT
  website_pageviews.website_session_id,
  MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM
  website_pageviews
WHERE
  website_pageviews.created_at < '2012-06-14'
GROUP BY
  website_pageviews.website_session_id;

DROP TABLE IF EXISTS sessions_w_landing_page
CREATE TEMPORARY TABLE sessions_w_landing_page AS
SELECT
  first_pageview.website_session_id,
  website_pageviews.pageview_url AS landing_page
FROM
  first_pageview
LEFT JOIN
  website_pageviews
ON
  website_pageviews.website_pageview_id = first_pageview.min_pv_id;

DROP TABLE IF EXISTS bounced_sessions_only
CREATE TEMPORARY TABLE bounced_sessions_only AS
SELECT
  sessions_w_landing_page.website_session_id,
  sessions_w_landing_page.landing_page,
  COUNT(website_pageviews.website_pageview_id) AS count_of_pageviews
FROM
  sessions_w_landing_page
LEFT JOIN
  website_pageviews
  ON website_pageviews.website_session_id = sessions_w_landing_page.website_session_id
GROUP BY
  sessions_w_landing_page.website_session_id,
  sessions_w_landing_page.landing_page
HAVING
  count(website_pageviews.website_pageview_id) = 1;
-- Calculate bounce rate 1
SELECT
  COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions,
  COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
  COUNT(DISTINCT bounced_sessions_only.website_session_id) / COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
FROM
  sessions_w_landing_page
LEFT JOIN bounced_sessions_only
  ON sessions_w_landing_page.website_session_id =  bounced_sessions_only.website_session_id;
--Alternative
-- Create a temporary table to store total sessions and bounced sessions
CREATE TEMPORARY TABLE total_bounced_sessions AS
SELECT
  COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN bounced_sessions_only.website_session_id IS NOT NULL THEN sessions_w_landing_page.website_session_id END) AS bounced_sessions
FROM
  sessions_w_landing_page
LEFT JOIN bounced_sessions_only
  ON sessions_w_landing_page.website_session_id =  bounced_sessions_only.website_session_id;
-- Calculate bounce rate
SELECT
  total_sessions,
  bounced_sessions,
  bounced_sessions / total_sessions AS bounce_rate
FROM
  total_bounced_sessions;

-- Paid search landing page comparison