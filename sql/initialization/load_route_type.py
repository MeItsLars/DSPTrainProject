import os
import csv
import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=[HOST] dbname=transport user=postgres password=[PASSWORD]")
conn.autocommit = True
cursor = conn.cursor()

with open("data.csv", 'r', encoding='utf-8') as f:
    csv_reader = csv.reader(f, delimiter=',', quotechar='"')
    lines = list(csv_reader)
    for line in lines:
        code = line[0]
        name = line[1]
        insert_query = "INSERT INTO route_types (code, name) VALUES (%s, %s)"
        cursor.execute(insert_query, (code, name))
        conn.commit()



# Close the connection to the PostgreSQL database
cursor.close()