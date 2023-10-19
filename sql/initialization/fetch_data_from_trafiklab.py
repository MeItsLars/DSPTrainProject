import os
import shutil
import zipfile

data_url = 'https://opendata.samtrafiken.se/gtfs-sweden/sweden.zip?key=af66205e225149c3b7415cc43665b3a0'

# Delete old data/gtfs-sverige-3 directory
if os.path.exists('./data/gtfs-sverige-3'):
    print('Deleting old data')
    shutil.rmtree('./data/gtfs-sverige-3')

# Create data folder
if not os.path.exists('data'):
    os.makedirs('data')

# Download the data
print('Downloading data from', data_url)

os.system('curl -H "Accept-Encoding: gzip" -o ./data/gtfs-sverige-3.zip ' + data_url)

# Unzip the data
print('Unzipping data')
with zipfile.ZipFile('./data/gtfs-sverige-3.zip', 'r') as zip_ref:
    zip_ref.extractall('./data/gtfs-sverige-3')

# Remove the zip file
print('Removing zip file')
os.remove('./data/gtfs-sverige-3.zip')

print('Done')