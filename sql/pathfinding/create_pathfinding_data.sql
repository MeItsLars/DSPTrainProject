CREATE TABLE IF NOT EXISTS nodes (
    stop_id BIGINT NOT NULL,
    stop_lat REAL NOT NULL,
    stop_lon REAL NOT NULL,
    FOREIGN KEY (stop_id) REFERENCES stops (stop_id)
);

CREATE TABLE IF NOT EXISTS edges (
    edge_id SERIAL PRIMARY KEY,
    trip_id BIGINT,
    from_stop_id BIGINT NOT NULL,
    to_stop_id BIGINT NOT NULL,
    travel_time REAL NOT NULL,
    start_time INTEGER NOT NULL,
    edge_type INTEGER NOT NULL,
    FOREIGN KEY (from_stop_id) REFERENCES stops (stop_id),
    FOREIGN KEY (to_stop_id) REFERENCES stops (stop_id)
);

CREATE INDEX IF NOT EXISTS edges_from_stop_id_idx ON edges (from_stop_id);

CREATE OR REPLACE FUNCTION create_nodes_and_edges()
RETURNS void AS $$ 
BEGIN
    SET statement_timeout = 120000;

    DELETE FROM nodes;
    DELETE FROM edges;

    -- Copy data from stops to nodes
    INSERT INTO nodes (stop_id, stop_lat, stop_lon) SELECT stop_id, stop_lat, stop_lon FROM stops;

    -- Fill the edges table with data from all the various tables
    -- 1. Add transfers to the edges table
    INSERT INTO edges (trip_id, from_stop_id, to_stop_id, travel_time, start_time, edge_type)
    SELECT -1, from_stop_id, to_stop_id, min_transfer_time, -1, 0 FROM transfers;
    
    -- 2. Add the edges between stops in the same trip
    INSERT INTO edges (trip_id, from_stop_id, to_stop_id, travel_time, start_time, edge_type)
    SELECT s1.trip_id, s1.stop_id, s2.stop_id, s2.arrival_time - s1.departure_time, s1.departure_time, 1
    FROM stop_times AS s1
    INNER JOIN stop_times AS s2 ON s1.trip_id = s2.trip_id
    WHERE s1.stop_sequence + 1 = s2.stop_sequence;
END;
$$ LANGUAGE plpgsql;