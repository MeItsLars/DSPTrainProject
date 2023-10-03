import os
import csv
import psycopg2

# Create connection to the PostgreSQL database
conn = psycopg2.connect("host=188.165.199.47 dbname=transport user=postgres password=TukTukTrain")
conn.autocommit = True
cursor = conn.cursor()

data_folder = 'data/gtfs-sverige-2'
converted_data_folder = 'data/gtfs-sverige-2-converted'
files = ['agency.txt', 'calendar.txt', 'calendar_dates.txt', 'routes.txt', 
         'trips.txt', 'stops.txt', 'stop_times.txt', 'transfers.txt']

# Create converted data folder
if not os.path.exists(converted_data_folder):
    os.makedirs(converted_data_folder)

for file in files:
    data_file = data_folder + '/' + file
    converted_data_file = converted_data_folder + '/' + file[:-4] + "_converted.txt"

    # First, we must convert comma-separated values to semi-colon-separated values.
    # This is because the GTFS data uses commas in some fields, which messes up the
    # loading into PostgreSQL.
    print('Converting data from', file)
    with open(data_file, 'r', encoding='utf-8') as f:
        csv_reader = csv.reader(f, delimiter=',', quotechar='"')
        lines = list(csv_reader)

        with open(converted_data_file, 'w', encoding='utf-8', newline='') as f_converted:
            csv_writer = csv.writer(f_converted, delimiter=';', quotechar='"')
            csv_writer.writerows(lines)

    # Now we can load the data into the database
    print('Loading data into', file[:-4], 'table')
    with open(converted_data_file, 'r', encoding='utf-8') as f:
        try:
            # Skip the header
            next(f)

            # Load the data
            cursor.copy_from(f, table=file[:-4], sep=';', null='')

            print('Data loaded successfully')
        except Exception as e:
            print('Error loading data:', e)
            print('Was the data already loaded?')
            print('Skipping to next file')
        

# Close the connection to the PostgreSQL database
cursor.close()