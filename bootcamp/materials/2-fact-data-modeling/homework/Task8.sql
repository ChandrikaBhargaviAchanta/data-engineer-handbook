WITH yesterday AS (
    SELECT
         host,
         month_start,
         host_hits,
         unique_visitors
    FROM
        host_activity_reduced
    WHERE
        month_start = '2023-01-01'::DATE
),
-- Get the today's data from events table and generate the required metrics using group by host
today AS (
    SELECT
        host,
        DATE_TRUNC('month', event_time::DATE)::DATE AS month_start,
        DATE_TRUNC('day', event_time::DATE)::DATE AS today_date,
        COUNT(1) AS num_hits, -- To calculate the number of daily host hits
        COUNT(DISTINCT user_id) AS unique_hits -- To calculate the number UNIQUE visitors to the host
    FROM
        events
    WHERE
        DATE_TRUNC('day', event_time::DATE) = '2023-01-31'::DATE
    GROUP BY 
         host,
		 DATE_TRUNC('month', event_time::DATE)::DATE,
		 DATE_TRUNC('day', event_time::DATE)
)
-- Load the data into host_activity_reduced using FULL OUTER JOIN with NULL handling 
INSERT INTO host_activity_reduced
SELECT
     COALESCE(y.host, t.host) AS host,
    COALESCE(y.month_start, t.month_start) AS month_start,
    -- there may be new host entries in mid of month, in this case generate 0 values into array as of yesterday and add today data from metrics
    COALESCE(y.host_hits,
           array_fill(0, ARRAY[COALESCE(t.today_date - t.month_start, 0)]))
         ||ARRAY[COALESCE(t.num_hits,0)] AS host_hits,
    COALESCE(y.unique_visitors,
           array_fill(0, ARRAY[COALESCE(t.today_date - t.month_start, 0)]))
        ||ARRAY[COALESCE(t.unique_hits,0)] AS unique_visitors
FROM
    yesterday y
FULL OUTER JOIN
    today t
    ON y.host = t.host
    AND y.month_start = t.month_start
-- below criteria is as we will have as yesterday data in table already & we wanted to overwrite it with as of today data
ON CONFLICT (host, month_start)
DO UPDATE SET host_hits = EXCLUDED.host_hits, unique_visitors = EXCLUDED.unique_visitors;