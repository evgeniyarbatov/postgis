CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE activity_data (
    id SERIAL PRIMARY KEY,
    time TIMESTAMP WITH TIME ZONE,
    activity_type VARCHAR(50),
    filename TEXT,
    location GEOMETRY(Point, 4326),
    elevation DECIMAL,
    cadence INT,
    heartrate INT,
    power INT
);

-- Temporary table to load CSV data
CREATE TEMP TABLE tmp_data (
    time TIMESTAMP WITH TIME ZONE,
    activity_type VARCHAR(50),
    filename TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    elevation DECIMAL,
    cadence INT,
    heartrate INT,
    power INT
);

-- Load data into the temporary table
COPY tmp_data(time, activity_type, filename, latitude, longitude, elevation, cadence, heartrate, power)
FROM '/data/gpx-file.csv'
DELIMITER ','
CSV HEADER;

-- Insert data from the temporary table to the actual table with geometry transformation
INSERT INTO activity_data (time, activity_type, filename, location, elevation, cadence, heartrate, power)
SELECT time, activity_type, filename, ST_SetSRID(ST_MakePoint(longitude, latitude), 4326), elevation, cadence, heartrate, power
FROM tmp_data;

-- Drop the temporary table after use
DROP TABLE tmp_data;