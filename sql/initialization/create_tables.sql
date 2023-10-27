CREATE TABLE IF NOT EXISTS agency (
    agency_id BIGINT NOT NULL,
    agency_name TEXT NOT NULL,
    agency_url TEXT NOT NULL,
    agency_timezone TEXT NOT NULL,
    agency_lang TEXT,
    agency_fare_url TEXT,
    PRIMARY KEY (agency_id)
);

CREATE TABLE IF NOT EXISTS calendar (
    service_id BIGINT NOT NULL,
    monday INTEGER NOT NULL,
    tuesday INTEGER NOT NULL,
    wednesday INTEGER NOT NULL,
    thursday INTEGER NOT NULL,
    friday INTEGER NOT NULL,
    saturday INTEGER NOT NULL,
    sunday INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (service_id)
);

CREATE TABLE IF NOT EXISTS calendar_dates (
    service_id BIGINT NOT NULL,
    date DATE NOT NULL,
    exception_type INTEGER NOT NULL,
    PRIMARY KEY (service_id, date),
    FOREIGN KEY (service_id) REFERENCES calendar (service_id)
);

CREATE TABLE IF NOT EXISTS routes (
    route_id TEXT NOT NULL,
    agency_id BIGINT NOT NULL,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type INTEGER NOT NULL,
    route_desc TEXT,
    PRIMARY KEY (route_id),
    FOREIGN KEY (agency_id) REFERENCES agency (agency_id)
);

CREATE TABLE IF NOT EXISTS trips (
    route_id TEXT NOT NULL,
    service_id BIGINT NOT NULL,
    trip_id BIGINT NOT NULL,
    trip_headsign TEXT,
    direction_id INTEGER,
    shape_id BIGINT,
    PRIMARY KEY (trip_id),
    FOREIGN KEY (route_id) REFERENCES routes (route_id),
    FOREIGN KEY (service_id) REFERENCES calendar (service_id)
);

CREATE TABLE IF NOT EXISTS stops (
    stop_id BIGINT NOT NULL,
    stop_name TEXT NOT NULL,
    stop_lat REAL NOT NULL,
    stop_lon REAL NOT NULL,
    location_type INTEGER,
    parent_station BIGINT,
    platform_code TEXT,
    PRIMARY KEY (stop_id)
);

CREATE TABLE IF NOT EXISTS stop_times (
    trip_id BIGINT NOT NULL,
    arrival_time INTEGER NOT NULL,
    departure_time INTEGER NOT NULL,
    stop_id BIGINT NOT NULL,
    stop_sequence INTEGER NOT NULL,
    stop_headsign TEXT,
    pickup_type INTEGER,
    drop_off_type INTEGER,
    shape_dist_traveled REAL,
    timepoint INTEGER,
    PRIMARY KEY (trip_id, stop_sequence),
    FOREIGN KEY (trip_id) REFERENCES trips (trip_id),
    FOREIGN KEY (stop_id) REFERENCES stops (stop_id)
);

CREATE TABLE IF NOT EXISTS transfers (
    from_stop_id BIGINT NOT NULL,
    to_stop_id BIGINT NOT NULL,
    transfer_type INTEGER NOT NULL,
    min_transfer_time INTEGER,
    from_trip_id BIGINT,
    to_trip_id BIGINT,
    FOREIGN KEY (from_stop_id) REFERENCES stops (stop_id),
    FOREIGN KEY (to_stop_id) REFERENCES stops (stop_id),
    FOREIGN KEY (from_trip_id) REFERENCES trips (trip_id),
    FOREIGN KEY (to_trip_id) REFERENCES trips (trip_id)
);


CREATE TABLE IF NOT EXISTS attributions (
    trip_id BIGINT NOT NULL,
    organization_name TEXT,
    is_operator INTEGER NOT NULL,
    FOREIGN KEY (trip_id) REFERENCES trips (trip_id)
);

CREATE TABLE IF NOT EXISTS route_types (
    code INT NOT NULL,
    name TEXT,
    PRIMARY KEY (code)
);