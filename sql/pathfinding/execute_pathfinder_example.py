import psycopg2
import sys

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

def find_route(start_stop, end_stop, travel_day, travel_time):
    travel_time_converted = int(travel_time.split(":")[0]) * 3600 + int(travel_time.split(":")[1]) * 60 + int(travel_time.split(":")[2])
    print("Executing pathfinder from stop {} to stop {} on {} at {} ({} seconds)".format(start_stop, end_stop, travel_day, travel_time, travel_time_converted))
    print("Query: SELECT astar_search({}, {}, TO_DATE('{}', 'DD-MM-YYYY'), {});".format(start_stop, end_stop, travel_day, travel_time_converted))

    # Join the obtained table with the stops table to get the stop names
    query = """
    SELECT
        CONCAT(s1.stop_name, COALESCE(CONCAT(' (', s1.platform_code, ')'), '')) AS s1_stop,
        CONCAT(s2.stop_name, COALESCE(CONCAT(' (', s2.platform_code, ')'), '')) AS s2_stop,
        e.trip_id, r.route_short_name, st.stop_headsign, r.route_type, e.travel_time, e.departure_time, t.service_id
    FROM edges e
    INNER JOIN (SELECT astar_search({}, {}, TO_DATE('{}', 'DD-MM-YYYY'), {}) AS edge_id) AS pathfinder_result
        ON e.edge_id = pathfinder_result.edge_id
    INNER JOIN stops s1 ON e.from_stop_id = s1.stop_id
    INNER JOIN stops s2 ON e.to_stop_id = s2.stop_id
    INNER JOIN stop_times st ON e.trip_id = st.trip_id AND e.from_stop_id = st.stop_id
    INNER JOIN trips t ON e.trip_id = t.trip_id
    INNER JOIN routes r ON t.route_id = r.route_id
    ORDER BY e.departure_time ASC
    """.format(start_stop, end_stop, travel_day, travel_time_converted)
    cursor.execute(query)

    if (cursor.rowcount == 0):
        print("No route found")
        return

    result_stops = cursor.fetchall()
    print("Pathfinder result: ")
    max_from_stop_name_length = max([len(row[0]) for row in result_stops])
    max_to_stop_name_length = max([len(row[1]) for row in result_stops])
    max_route_name_length = max([len(row[4]) if row[4] is not None else 0 for row in result_stops])
    data_format = "{:<8} | {:<{}} | {:<{}} | {:<8} | {:<18} | {:<6} | {:<5} | {:<{}} | {:<4}"
    header = data_format.format(
        "Dep.Time", "From", max_from_stop_name_length, "To", max_to_stop_name_length, "Arv.Time", "Trip ID", "SID", "RID", "Route", max_route_name_length, "Type"
    )
    print(header)
    print("-" * len(header))
    last_trip_id = None
    for row in result_stops:
        stop1 = row[0] if row[0] is not None else "-"
        stop2 = row[1] if row[1] is not None else "-"
        trip_id = row[2] if row[2] is not None else "-"
        route_short_name = row[3] if row[3] is not None else "-"
        route_long_name = row[4] if row[4] is not None else "-"
        route_type = row[5] if row[5] is not None else "-"
        travel_time = int(row[6] if row[6] is not None else 0)
        departure_time = row[7] if row[7] is not None else 0
        arrival_time = departure_time + travel_time
        service_id = row[8] if row[8] is not None else "-"

        if trip_id != last_trip_id and last_trip_id is not None:
            print()
        last_trip_id = trip_id

        leavesAt = "{}:{:02d}:{:02d}".format(departure_time // 3600, (departure_time % 3600) // 60, departure_time % 60)
        arrivesAt = "{}:{:02d}:{:02d}".format(arrival_time // 3600, (arrival_time % 3600) // 60, arrival_time % 60)
        text = data_format.format(
            leavesAt, stop1, max_from_stop_name_length, stop2, max_to_stop_name_length, arrivesAt, trip_id, service_id, route_short_name, route_long_name, max_route_name_length, route_type
        )
        utf8text = text.encode('utf-8')
        sys.stdout.buffer.write(utf8text)
        print()

umea_alidhem = 55698 # Ålidhems Centrum
umea_alidhojd = 55668 # Ålidhöjd
umea_vasaplan = 55785 # Vasaplan
umea_universum = 55664 # Universum
umea_marknadsgatan = 56957 # Marknadsgatan (Ikea)
umea_ostra = 1581 # Umeå Östra
umea_busstation = 53785 # Umeå Busstation
umea_central = 190 # Umeå Centralstation
ornskoldsvik_rese = 1570 # Örnsköldsvik Resecentrum
storuman_resecentrum = 428 # Storuman Resecentrum
uppsala_central = 5 # Uppsala Centralstation

# find_route(umea_universum, umea_alidhem, '20-10-2023', '16:05:00')
# find_route(umea_universum, umea_alidhem, '20-10-2023', '16:00:00')
# find_route(storuman_resecentrum, uppsala_central, '21-10-2023', '04:00:00')
find_route(storuman_resecentrum, umea_busstation, '21-10-2023', '04:00:00')
find_route(umea_central, uppsala_central, '21-10-2023', '10:22:00')

# Close the connection to the PostgreSQL database
cursor.close()