import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=postgres user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

# Check if the 'transport' database exists
cursor.execute("SELECT datname FROM pg_catalog.pg_database WHERE datname='transport'")
exists = cursor.fetchone()

# If the database does not exist, create it
if exists:
    delete = input("Database 'transport' already exists. Delete? (y/n) ")
    if delete == 'y':
        cursor.execute("DROP DATABASE transport WITH (FORCE)")
        print("Database 'transport' deleted successfully")
    else:
        exit()

cursor.execute("CREATE DATABASE transport ENCODING 'UTF8'")
print("Database 'transport' created successfully")

# Close the connection to the PostgreSQL database
cursor.close()