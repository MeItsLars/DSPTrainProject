import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=[HOST] dbname=transport user=postgres password=[PASSWORD]")
conn.autocommit = True
cursor = conn.cursor()

# Execute the entire 'create_tables.sql' file at once
with open('sql/initialization/create_tables.sql', 'r', encoding='utf-8') as f:
    cursor.execute(f.read())
    print("Tables created successfully")

# Close the connection to the PostgreSQL database
cursor.close()
conn.close()