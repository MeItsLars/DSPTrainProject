import psycopg2
import sys

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

start_stop = 9022050055698001 # Umeå Ålidhem
# end_stop = 9022050056957002 # Umeå Marknadsgatan (Ikea)
end_stop = 9022050059027001 # Vindeln Centrum
travel_day = '17-10-2023'

print("Executing pathfinder from stop {} to stop {}...".format(start_stop, end_stop))

# Join the obtained table with the stops table to get the stop names
query = """
SELECT
    CONCAT(s1.stop_name, COALESCE(CONCAT(' (', s1.platform_code, ')'), '')) AS s1_stop,
    CONCAT(s2.stop_name, COALESCE(CONCAT(' (', s2.platform_code, ')'), '')) AS s2_stop,
    e.trip_id, r.route_short_name, st.stop_headsign, r.route_type, e.travel_time, e.departure_time
FROM edges e
INNER JOIN (SELECT astar_search({}, {}, TO_DATE('{}', 'DD-MM-YYYY'), {}) AS edge_id) AS pathfinder_result
    ON e.edge_id = pathfinder_result.edge_id
INNER JOIN stops s1 ON e.from_stop_id = s1.stop_id
INNER JOIN stops s2 ON e.to_stop_id = s2.stop_id
INNER JOIN stop_times st ON e.trip_id = st.trip_id AND e.from_stop_id = st.stop_id
INNER JOIN trips t ON e.trip_id = t.trip_id
INNER JOIN routes r ON t.route_id = r.route_id
ORDER BY e.departure_time ASC
""".format(start_stop, end_stop, travel_day, 0)
cursor.execute(query)

result_stops = cursor.fetchall()
print("Pathfinder result: ")
max_from_stop_name_length = max([len(row[0]) for row in result_stops])
max_to_stop_name_length = max([len(row[1]) for row in result_stops])
max_route_name_length = max([len(row[4]) if row[4] is not None else 0 for row in result_stops])
header = "{:<8} | {:<{}} | {:<{}} | {:<8} | {:<18} | {:<5} | {:<{}} | {:<4} | {:<6}".format(
    "Dep.Time", "From", max_from_stop_name_length, "To", max_to_stop_name_length, "Arv.Time", "Trip ID", "RID", "Route", max_route_name_length, "Type", "Time"
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

    if trip_id != last_trip_id and last_trip_id is not None:
        print()
    last_trip_id = trip_id

    leavesAt = "{}:{:02d}:{:02d}".format(departure_time // 3600, (departure_time % 3600) // 60, departure_time % 60)
    arrivesAt = "{}:{:02d}:{:02d}".format(arrival_time // 3600, (arrival_time % 3600) // 60, arrival_time % 60)
    text = "{:<8} | {:<{}} | {:<{}} | {:<8} | {:<18} | {:<5} | {:<{}} | {:<4} | {:<6}\n".format(
        leavesAt, stop1, max_from_stop_name_length, stop2, max_to_stop_name_length, arrivesAt, trip_id, route_short_name, route_long_name, max_route_name_length, route_type, travel_time
    )
    utf8text = text.encode('utf-8')
    sys.stdout.buffer.write(utf8text)

# Close the connection to the PostgreSQL database
cursor.close()