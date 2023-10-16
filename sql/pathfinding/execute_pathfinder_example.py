import psycopg2
import sys

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

start_stop = 740045443 # Umeå Ålidhem
end_stop = 740072812 # Umeå Marknadsgatan
# end_stop = 740020116 # Umeå Vasaplan
travel_day = '17-10-2023'

print("Executing pathfinder from stop {} to stop {}...".format(start_stop, end_stop))

# Join the obtained table with the stops table to get the stop names
query = """
SELECT s1.stop_name, s2.stop_name, e.trip_id, e.travel_time, e.departure_time, e.transport_type
FROM edges e
INNER JOIN (SELECT astar_search({}, {}, TO_DATE('{}', 'DD-MM-YYYY'), {}) AS edge_id) AS pathfinder_result ON e.edge_id = pathfinder_result.edge_id
INNER JOIN stops s1 ON e.from_stop_id = s1.stop_id
INNER JOIN stops s2 ON e.to_stop_id = s2.stop_id
ORDER BY e.departure_time ASC
""".format(start_stop, end_stop, travel_day, 0)
cursor.execute(query)

result_stops = cursor.fetchall()
print("Pathfinder result: ")
for row in result_stops:
    leavesAt = "{}:{}:{}".format(row[4] // 3600, (row[4] % 3600) // 60, row[4] % 60)
    text = "{} | {} -> {} (Trip ID: {}, Travel time (s): {})\n".format(leavesAt, row[0], row[1], row[2], row[3])
    utf8text = text.encode('utf-8')
    sys.stdout.buffer.write(utf8text)

# Close the connection to the PostgreSQL database
cursor.close()