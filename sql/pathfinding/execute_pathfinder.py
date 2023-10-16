import psycopg2
import sys

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

start_stop = 740000932
end_stop = 740051769

print("Executing pathfinder from stop {} to stop {}...".format(start_stop, end_stop))
# Join the obtained table with the stops table to get the stop names
query = """
SELECT stops.stop_id, stops.stop_name, stops.stop_lat, stops.stop_lon FROM stops
INNER JOIN (
    SELECT astar_search({}, {}) AS stop_id
) AS pathfinder_result ON stops.stop_id = pathfinder_result.stop_id
""".format(start_stop, end_stop)
cursor.execute(query)

result_stops = cursor.fetchall()
print("Pathfinder result:")
# Reverse loop
i = 1
for stop in reversed(result_stops):
    sys.stdout.buffer.write(("{}: {} ({}, {}, {})".format(i, stop[1], stop[0], stop[2], stop[3])).encode('utf-8'))
    sys.stdout.buffer.write("\n".encode('utf-8'))
    i += 1

# Close the connection to the PostgreSQL database
cursor.close()