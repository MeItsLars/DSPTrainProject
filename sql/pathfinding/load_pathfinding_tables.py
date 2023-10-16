import os
import csv
import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

print("Dropping existing tables and functions...")
# Delete 'nodes' and 'edges' tables
cursor.execute("DROP TABLE IF EXISTS nodes")
cursor.execute("DROP TABLE IF EXISTS edges")
# Delete 'create_nodes_and_edges()' function
cursor.execute("DROP FUNCTION IF EXISTS create_nodes_and_edges() CASCADE")

print("Creating new tables and functions...")
# Execute the create_pathfinding_data.sql file
with open('sql/pathfinding/create_pathfinding_data.sql', 'r', encoding='utf-8') as f:
    cursor.execute(f.read())
    print("Tables created successfully")

print("Loading nodes and edges... (this may take a while)")
cursor.execute("SELECT create_nodes_and_edges()")

print("Creating indexes...")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_edges_from_stop_id ON edges (from_stop_id)")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_service_id_edges ON edges (service_id)")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_service_id_calendar_dates ON calendar_dates (service_id)")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_service_id_calendar ON calendar (service_id)")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_day_calendar_dates ON calendar_dates (date)")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_start_end_day_calendar ON calendar (start_date, end_date)")

print("Done!")

# Close the connection to the PostgreSQL database
cursor.close()