import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

# Execute the entire 'create_tables.sql' file at once
with open('sql/create_tables.sql', 'r', encoding='utf-8') as f:
    cursor.execute(f.read())
    print("Tables created successfully")

# Close the connection to the PostgreSQL database
cursor.close()
conn.close()