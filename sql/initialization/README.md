Hey! Quick explanation as to how to store the data in the database.

Step 1: Run 'fetch_data_from_trafiklab.py' to fetch the data from Trafiklab's API. This will create a directory called gtfs-sverige-2, containing all the data.
Step 2: Run 'create_database.py' to delete the old database and create a new one.
Step 3: Run 'create_tables.py'. This runs the SQL script 'create_tables.sql' which creates all the tables in the database.
Step 4: Run 'load_data.py'. This takes a while to run (on my device about 2 minutes). It will load all the data from the gtfs-sverige-2 directory and convert it to a different format. Then, it will load the data into the database.