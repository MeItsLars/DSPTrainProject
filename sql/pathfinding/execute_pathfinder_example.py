import psycopg2
import sys

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

start_stop = 740045443 # Umeå Ålidhem
# end_stop = 740020116 # Umeå Vasaplan
end_stop = 740072812 # Umeå Marknadsgatan

print("Executing pathfinder from stop {} to stop {}...".format(start_stop, end_stop))

# Join the obtained table with the stops table to get the stop names
query = """
SELECT s1.stop_name, s2.stop_name, e.trip_id, e.travel_time, e.start_time, e.edge_type
FROM edges e
INNER JOIN (SELECT astar_search({}, {}) AS edge_id) AS pathfinder_result ON e.edge_id = pathfinder_result.edge_id
INNER JOIN stops s1 ON e.from_stop_id = s1.stop_id
INNER JOIN stops s2 ON e.to_stop_id = s2.stop_id
ORDER BY e.start_time ASC
""".format(start_stop, end_stop)
cursor.execute(query)

result_stops = cursor.fetchall()
print("Pathfinder result: ")
for row in result_stops:
    text = "{} -> {} (Trip ID: {}, Travel time (s): {}, Leaves at: {}, Travel type: {})\n".format(row[0], row[1], row[2], row[3], row[4], row[5])
    utf8text = text.encode('utf-8')
    sys.stdout.buffer.write(utf8text)

# Close the connection to the PostgreSQL database
cursor.close()