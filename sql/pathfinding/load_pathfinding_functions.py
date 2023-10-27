import os
import csv
import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=[HOST] dbname=transport user=postgres password=[PASSWORD]")
conn.autocommit = True
cursor = conn.cursor()

with open('sql/pathfinding/create_pathfinding_functions.sql', 'r', encoding='utf-8') as f:
    cursor.execute(f.read())
    print("Functions created successfully")

# Close the connection to the PostgreSQL database
cursor.close()