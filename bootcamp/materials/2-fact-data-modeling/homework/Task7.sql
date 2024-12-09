CREATE TABLE host_activity_reduced (
    host TEXT,
    month_start DATE,
    host_hits REAL[],
    unique_visitors REAL[],
    PRIMARY KEY (host, month_start)
);