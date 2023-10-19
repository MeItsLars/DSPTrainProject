CREATE EXTENSION IF NOT EXISTS hstore;

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
    -- by the maximum speed of a train (200 km/h, or 55.5556 m/s)
    travel_time := distance / 55;

    RETURN travel_time;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reconstruct_path(used_edge_id hstore, from_node BIGINT, to_node BIGINT)
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
        SELECT e.from_stop_id INTO next FROM edges e WHERE e.edge_id = (used_edge_id -> current::TEXT)::BIGINT;
        -- Insert the edge_id into the temporary table
        INSERT INTO temp_result VALUES ((used_edge_id -> current::TEXT)::BIGINT);
        current := next;
    END LOOP;
    -- Return the results from the temporary table
    RETURN QUERY SELECT edge_id2 FROM temp_result;
    -- Drop the temporary table
    DROP TABLE temp_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION astar_search(from_node BIGINT, to_node BIGINT, travel_day DATE, travel_time INTEGER)
RETURNS TABLE (edge_id BIGINT) AS $$
DECLARE
    openSet BIGINT[];
    closedSet BIGINT[];
    cameFrom hstore;
    cameFromTripId hstore;
    gScore hstore;
    fScore hstore;
    arrivalTime hstore;
    current BIGINT;
	node BIGINT;
    neighbor_edge RECORD;
    previous_edge_trip_id BIGINT;
    same_stop_transfer_penalty REAL;
    tentative_gScore REAL;

    temp_var_1 RECORD;
    temp_var_2 RECORD;
    temp_var_3 RECORD;
BEGIN
    RAISE NOTICE 'Starting A* search from % to % on % at %', from_node, to_node, travel_day, travel_time;

    -- Initialize the open set with the from_node
    openSet := array[from_node];

    -- Initialize other arrays
    closedSet := array[]::BIGINT[];
    cameFrom := ''::hstore;
    cameFromTripId := ''::hstore;
    gScore := hstore(from_node::TEXT, '0');
    fScore := hstore(from_node::TEXT, distance_heuristic(from_node, to_node)::TEXT);
    arrivalTime := hstore(from_node::TEXT, travel_time::TEXT);

    -- Loop until the open set is empty
    WHILE array_length(openSet, 1) > 0 LOOP
        -- Get the node in the open set with the lowest fScore
        current := openSet[1];
        FOREACH node IN ARRAY openSet LOOP
            IF (fScore -> node::TEXT)::REAL < (fScore -> current::TEXT)::REAL THEN
                current := node;
            END IF;
        END LOOP;
        
        SELECT * INTO temp_var_1 FROM stops WHERE stop_id = current;
        RAISE NOTICE 'Current node: % (gScore: %, heuristic: %) (ID: %)', 
            CONCAT(temp_var_1.stop_name, COALESCE(CONCAT(' (', temp_var_1.platform_code, ')'), '')),
            (gScore -> current::TEXT)::REAL, 
            (fScore -> current::TEXT)::REAL - (gScore -> current::TEXT)::REAL,
            temp_var_1.stop_id;
        

        -- If the current node is the to_node, we have found the path
        IF current = to_node THEN
            RAISE NOTICE 'Path found';
            RETURN QUERY SELECT * FROM reconstruct_path(cameFrom, from_node, to_node);
            RETURN;
        END IF;

        -- Remove the current node from the open set
        openSet := array_remove(openSet, current);

        -- Add the current node to the closed set
        closedSet := array_append(closedSet, current);

        -- Get the neighbors of the current node that are reachable on the given day
        FOR neighbor_edge IN (
            SELECT e.edge_id, e.trip_id, e.service_id, e.from_stop_id, e.to_stop_id, e.travel_time, e.transfer_penalty, e.departure_time
            FROM edges e
            WHERE e.from_stop_id = current AND (
                e.departure_time IS NULL OR (
                    e.departure_time >= (arrivalTime -> current::TEXT)::REAL
                    -- AND e.departure_time <= (arrivalTime -> current::TEXT)::REAL + 1800
                    AND EXISTS (
                        SELECT 1
                        FROM calendar_dates cd
                        WHERE cd.service_id = e.service_id AND cd.date = travel_day AND cd.exception_type = 1
                        -- INTERSECT
                        -- SELECT 1
                        -- FROM calendar c
                        -- WHERE c.service_id = e.service_id AND travel_day BETWEEN c.start_date AND c.end_date
                    )
                )
            )
        ) LOOP
            -- Tentative gScore:
            -- gScore to get to the last node
            -- travel time to get from the last node to the current node
            -- penalty for transferring
            -- waiting time at the last node
            tentative_gScore := (gScore -> current::TEXT)::REAL 
                                + neighbor_edge.travel_time 
                                + neighbor_edge.transfer_penalty
                                + COALESCE(neighbor_edge.departure_time - (arrivalTime -> current::TEXT)::REAL, 0);
            
            SELECT * INTO temp_var_2 FROM stops WHERE stop_id = neighbor_edge.to_stop_id;
            SELECT e.departure_time AS departure_time, e.trip_id AS trip_id, e.travel_time AS travel_time, r.route_short_name AS route_short_name, st.stop_headsign AS stop_headsign, t.service_id AS service_id
            INTO temp_var_3 FROM edges e
            LEFT JOIN stop_times st ON e.trip_id = st.trip_id AND e.from_stop_id = st.stop_id
            LEFT JOIN trips t ON e.trip_id = t.trip_id
            LEFT JOIN routes r ON t.route_id = r.route_id
            WHERE e.edge_id = neighbor_edge.edge_id;
            RAISE NOTICE '-> %, tentative gScore: % (ID: %) (Dep.T: %, TID: %, RID: %, Route: %, SID: %, TT: %) - gScore = % + % + % + %',
                CONCAT(temp_var_2.stop_name, COALESCE(CONCAT(' (', temp_var_2.platform_code, ')'), '')),
                tentative_gScore,
                temp_var_2.stop_id,
                temp_var_3.departure_time,
                temp_var_3.trip_id,
                temp_var_3.route_short_name,
                temp_var_3.stop_headsign,
                temp_var_3.service_id,
                temp_var_3.travel_time,
                (gScore -> current::TEXT)::REAL,
                neighbor_edge.travel_time,
                neighbor_edge.transfer_penalty,
                COALESCE(neighbor_edge.departure_time - (arrivalTime -> current::TEXT)::REAL, 0);

            -- If the previous and neighbor edges are both in vehicles but not the same trip, we add a 1 minute transfer penalty
            same_stop_transfer_penalty := 0;
            -- previous_edge_trip_id := (cameFromTripId -> current::TEXT)::BIGINT;
            -- IF previous_edge_trip_id IS NOT NULL AND neighbor_edge.trip_id IS NOT NULL AND previous_edge_trip_id != neighbor_edge.trip_id THEN
            --     tentative_gScore := tentative_gScore + 60;
            --     same_stop_transfer_penalty := 60;
            -- END IF;

            -- If the neighbor is in the closed set and the tentative gScore is greater than the gScore of the neighbor,
            -- we skip this neighbor
            IF neighbor_edge.to_stop_id = ANY(closedSet) AND tentative_gScore >= (gScore -> neighbor_edge.to_stop_id::TEXT)::REAL THEN
                CONTINUE;
            END IF;

            -- If the neighbor is not in the open set or the tentative gScore is less than the gScore of the neighbor,
            -- we add the neighbor to the open set and update the cameFrom, gScore and fScore arrays
            IF neighbor_edge.to_stop_id NOT IN (SELECT unnest(openSet)) OR tentative_gScore < (gScore -> neighbor_edge.to_stop_id::TEXT)::REAL THEN
                openSet := array_append(openSet, neighbor_edge.to_stop_id);
                cameFrom := cameFrom || hstore(neighbor_edge.to_stop_id::TEXT, neighbor_edge.edge_id::TEXT);
                cameFromTripId := cameFromTripId || hstore(neighbor_edge.to_stop_id::TEXT, neighbor_edge.trip_id::TEXT);
                gScore := gScore || hstore(neighbor_edge.to_stop_id::TEXT, tentative_gScore::TEXT);
                fScore := fScore || hstore(neighbor_edge.to_stop_id::TEXT, (tentative_gScore + distance_heuristic(neighbor_edge.to_stop_id, to_node))::TEXT);
                arrivalTime := arrivalTime || hstore(neighbor_edge.to_stop_id::TEXT, (COALESCE(neighbor_edge.departure_time::TEXT, arrivalTime -> current::TEXT)::REAL + neighbor_edge.travel_time + neighbor_edge.transfer_penalty + same_stop_transfer_penalty)::TEXT);
            END IF;
        END LOOP;
    END LOOP;

    -- If we reach this point, we have not found a path
    RAISE NOTICE 'No path found';
    RETURN;
END;
$$ LANGUAGE plpgsql;