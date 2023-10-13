import os
import shutil
import zipfile

data_url = 'https://api.resrobot.se/v2.1/gtfs/sweden.zip?accessId=1cea7f8f-1584-4cd2-bff7-8f5cc07d6361'

# Delete old data/gtfs-sverige-2 directory
if os.path.exists('./data/gtfs-sverige-2'):
    print('Deleting old data')
    shutil.rmtree('./data/gtfs-sverige-2')

# Create data folder
if not os.path.exists('data'):
    os.makedirs('data')

# Download the data
print('Downloading data from', data_url)
os.system('curl -o ./data/gtfs-sverige-2.zip ' + data_url)

# Unzip the data
print('Unzipping data')
with zipfile.ZipFile('./data/gtfs-sverige-2.zip', 'r') as zip_ref:
    zip_ref.extractall('./data/gtfs-sverige-2')

# Remove the zip file
print('Removing zip file')
os.remove('./data/gtfs-sverige-2.zip')

print('Done')