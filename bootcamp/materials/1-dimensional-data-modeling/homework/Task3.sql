--DROP TABLE IF EXISTS actors_history_scd;

CREATE TABLE actors_history_scd (
    actor TEXT,
    quality_class quality_class_type,
	is_active BOOLEAN,
	start_date INTEGER,
	end_date INTEGER
);