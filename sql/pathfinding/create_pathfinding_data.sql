CREATE TABLE IF NOT EXISTS nodes (
    stop_id BIGINT NOT NULL,
    stop_lat REAL NOT NULL,
    stop_lon REAL NOT NULL,
    FOREIGN KEY (stop_id) REFERENCES stops (stop_id)
);

CREATE TABLE IF NOT EXISTS edges (
    edge_id SERIAL PRIMARY KEY,
    edge_type INTEGER NOT NULL,
    trip_id BIGINT DEFAULT NULL,
    service_id BIGINT DEFAULT NULL,
    from_stop_id BIGINT NOT NULL,
    to_stop_id BIGINT NOT NULL,
    travel_time REAL NOT NULL DEFAULT 0,
    transfer_penalty REAL NOT NULL DEFAULT 0,
    departure_time INTEGER DEFAULT NULL,
    FOREIGN KEY (from_stop_id) REFERENCES stops (stop_id),
    FOREIGN KEY (to_stop_id) REFERENCES stops (stop_id)
);

CREATE OR REPLACE FUNCTION create_nodes_and_edges()
RETURNS void AS $$ 
BEGIN
    SET statement_timeout = 600000;

    DELETE FROM nodes;
    DELETE FROM edges;

    -- Copy data from stops to nodes
    INSERT INTO nodes (stop_id, stop_lat, stop_lon) SELECT stop_id, stop_lat, stop_lon FROM stops;

    -- Fill the edges table with data from all the various tables
    -- 1. Add stop -> stop edges for transfers
    INSERT INTO edges (edge_type, from_stop_id, to_stop_id, travel_time)
    SELECT 0, from_stop_id, to_stop_id, COALESCE(min_transfer_time, 0) FROM transfers
    WHERE transfer_type = 2 AND from_stop_id != to_stop_id;

    -- 2. Add the edges between stops and their parent stations.
    -- A: If the edge is from stop -> parent, the transfer penalty is 2
    INSERT INTO edges (edge_type, from_stop_id, to_stop_id, transfer_penalty)
    SELECT 1, s1.stop_id, s2.stop_id, t.min_transfer_time
    FROM stops AS s1
    INNER JOIN stops AS s2 ON s1.parent_station = s2.stop_id
    INNER JOIN transfers AS t ON s2.stop_id = t.from_stop_id
    WHERE t.from_stop_id = t.to_stop_id AND t.transfer_type = 2;
    -- B: If the edge is from parent -> stop, the transfer penalty is 0
    INSERT INTO edges (edge_type, from_stop_id, to_stop_id, transfer_penalty)
    SELECT 2, s1.stop_id, s2.stop_id, 0
    FROM stops AS s1
    INNER JOIN stops AS s2 ON s1.stop_id = s2.parent_station;
    
    -- 3. Add the edges between stops in the same trip
    INSERT INTO edges (edge_type, trip_id, service_id, from_stop_id, to_stop_id, travel_time, departure_time)
    SELECT 10, s1.trip_id, t.service_id, s1.stop_id, s2.stop_id, s2.arrival_time - s1.departure_time, s1.departure_time
    FROM stop_times AS s1
    INNER JOIN trips AS t ON s1.trip_id = t.trip_id
    INNER JOIN stop_times AS s2 ON s1.trip_id = s2.trip_id
    WHERE s1.stop_sequence + 1 = s2.stop_sequence;
END;
$$ LANGUAGE plpgsql;