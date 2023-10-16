-- CREATE TABLE IF NOT EXISTS nodes (
--     stop_id BIGINT NOT NULL,
--     stop_lat REAL NOT NULL,
--     stop_lon REAL NOT NULL,
--     FOREIGN KEY (stop_id) REFERENCES stops (stop_id)
-- );

-- CREATE TABLE IF NOT EXISTS edges (
--     from_stop_id BIGINT NOT NULL,
--     to_stop_id BIGINT NOT NULL,
--     distance REAL NOT NULL,
--     start_time INTEGER NOT NULL,
--     edge_type INTEGER NOT NULL,
--     FOREIGN KEY (from_stop_id) REFERENCES stops (stop_id),
--     FOREIGN KEY (to_stop_id) REFERENCES stops (stop_id)
-- );

CREATE OR REPLACE FUNCTION distance_heuristic(from_node BIGINT, to_node BIGINT)
RETURNS REAL AS $$
DECLARE
    from_lat REAL;
    from_lon REAL;
    to_lat REAL;
    to_lon REAL;
    delta_lat REAL;
    delta_lon REAL;
    a REAL;
    c REAL;
    distance REAL;
    travel_time REAL;
BEGIN
    -- Get the latitude and longitude of the from_node
    SELECT stop_lat, stop_lon INTO from_lat, from_lon
    FROM nodes
    WHERE stop_id = from_node;

    -- Get the latitude and longitude of the to_node
    SELECT stop_lat, stop_lon INTO to_lat, to_lon
    FROM nodes
    WHERE stop_id = to_node;

    -- Calculate the differences in latitude and longitude
    delta_lat := radians(to_lat - from_lat);
    delta_lon := radians(to_lon - from_lon);

    -- We apply the haversine function (https://en.wikipedia.org/wiki/Haversine_formula) to obtain the distance
    -- Step 1: Obtain hav(angle) using the haversine formula
    a := power(sin(delta_lat / 2), 2) + cos(radians(from_lat)) * cos(radians(to_lat)) * power(sin(delta_lon / 2), 2);
    -- Step 2: Obtain the distance by applying the inverse sine function
    c := 2 * atan2(sqrt(a), sqrt(1 - a));
    -- Step 3: Multiply by the radius of the Earth in meters to obtain the distance in meters
    -- Radius of the Earth in meters is approximately 6371000 metres (6,371 kilometers)
    -- At the poles, the radius is 6357000 metres (6,357 kilometers)
    -- As we need a heuristic (which underestimates the distance), we use the radius at the poles (which is smaller
    distance := 6357000 * c;

    -- Finally, we calculate the travel time (in seconds).
    -- As we need an underestimating heuristic, we will divide the distance
    -- by the maximum speed of a train (300 km/h, or 83.33 m/s)
    travel_time := distance / 83.33;

    RETURN travel_time;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reconstruct_path(used_edge_id BIGINT[], from_node BIGINT, to_node BIGINT)
RETURNS TABLE (edge_id BIGINT) AS $$
DECLARE
    current BIGINT;
    next BIGINT;
BEGIN
    -- We create a quick temporary table to store the results
    CREATE TEMP TABLE temp_result (edge_id2 BIGINT);

    -- Backtrack from the to_node to the from_node
    current := to_node;
    WHILE current != from_node LOOP
        -- Fetch the next stop ID
        SELECT e.from_stop_id INTO next FROM edges e WHERE e.edge_id = used_edge_id[current];
        -- Insert the edge_id into the temporary table
        INSERT INTO temp_result VALUES (used_edge_id[current]::BIGINT);
        current := next;
    END LOOP;
    -- Return the results from the temporary table
    RETURN QUERY SELECT edge_id2 FROM temp_result;
    -- Drop the temporary table
    DROP TABLE temp_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION astar_search(from_node BIGINT, to_node BIGINT)
RETURNS TABLE (edge_id BIGINT) AS $$
DECLARE
    openSet BIGINT[];
    closedSet BIGINT[];
    cameFrom BIGINT[];
    gScore REAL[];
    fScore REAL[];
    current BIGINT;
	node BIGINT;
    neighbor_edge RECORD;
    tentative_gScore REAL;
BEGIN
    -- Initialize the open set with the from_node
    openSet := array[from_node];

    -- Initialize other arrays
    closedSet := array[]::BIGINT[];
    cameFrom := array[]::BIGINT[];
    gScore := array[]::REAL[];
    fScore := array[]::REAL[];

    -- Initialize the gScore and fScore of the from_node
    gScore[from_node] := 0;
    fScore[from_node] := distance_heuristic(from_node, to_node);

    -- Loop until the open set is empty
    WHILE array_length(openSet, 1) > 0 LOOP
        RAISE NOTICE 'Open set: %', openSet;

        -- Get the node in the open set with the lowest fScore
        current := openSet[1];
        FOREACH node IN ARRAY openSet LOOP
            IF fScore[node] < fScore[current] THEN
                current := node;
            END IF;
        END LOOP;
        
        RAISE NOTICE 'Current node: %', current;

        -- If the current node is the to_node, we have found the path
        IF current = to_node THEN
            RAISE NOTICE 'Path found';
            RETURN QUERY SELECT * FROM reconstruct_path(cameFrom, from_node, to_node);
            RETURN;
        END IF;

        RAISE NOTICE 'Expanding...';

        -- Remove the current node from the open set
        openSet := array_remove(openSet, current);

        -- Add the current node to the closed set
        closedSet := array_append(closedSet, current);

        -- Get the neighbors of the current node
        FOR neighbor_edge IN (
            SELECT edges.edge_id, from_stop_id, to_stop_id, travel_time
            FROM edges
            WHERE from_stop_id = current
        ) LOOP
            tentative_gScore := gScore[current] + neighbor_edge.travel_time;
            RAISE NOTICE '> Neighbor: %', neighbor_edge.to_stop_id;
            RAISE NOTICE '  Tentative gScore: %', tentative_gScore;

            -- If the neighbor is in the closed set and the tentative gScore is greater than the gScore of the neighbor,
            -- we skip this neighbor
            IF neighbor_edge.to_stop_id = ANY(closedSet) AND tentative_gScore >= gScore[neighbor_edge.to_stop_id] THEN
                RAISE NOTICE ' Neighbor is closed (and higher gScore)';
                CONTINUE;
            END IF;

            -- If the neighbor is not in the open set or the tentative gScore is less than the gScore of the neighbor,
            -- we add the neighbor to the open set and update the cameFrom, gScore and fScore arrays
            IF neighbor_edge.to_stop_id NOT IN (SELECT unnest(openSet)) OR tentative_gScore < gScore[neighbor_edge.to_stop_id] THEN
                RAISE NOTICE ' Neighbor is not in open set or lower gScore';
                openSet := array_append(openSet, neighbor_edge.to_stop_id);
                cameFrom[neighbor_edge.to_stop_id] := neighbor_edge.edge_id;
                gScore[neighbor_edge.to_stop_id] := tentative_gScore;
                fScore[neighbor_edge.to_stop_id] := tentative_gScore + distance_heuristic(neighbor_edge.to_stop_id, to_node);
            END IF;
        END LOOP;
    END LOOP;

    -- If we reach this point, we have not found a path
    RAISE NOTICE 'No path found';
    RETURN;
END;
$$ LANGUAGE plpgsql;