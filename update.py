#!/usr/bin/python3

import json
import os
import re
import sys
import time
from datetime import datetime

DATA_PATH = '/opt/vault'

paths = sys.argv[1:]

if len(paths) > 1:
    raise AssertionError('Invalid associated array')

if not paths[0].startswith('declare -A items='):
    raise AssertionError('Invalid associated array')

paths = paths[0][18:-1]
print()
print()

match = re.findall('\[([\w \/.-]*)\]="([\w.]*)" ?', paths)
updated_path_names = {}

for ma in match:
    print(ma[0], ma[1])
    updated_path_names[ma[0]] = ma[1]


JSON_FILE_LOCATION = os.path.join(DATA_PATH, 'index.json')
FIRST_TIME = False

if not os.path.isfile(JSON_FILE_LOCATION):
    raise AssertionError('File not found')

# Read index file
try:
    with open(JSON_FILE_LOCATION) as f:
        backup_data = json.load(f)

    backup_data['paths'].update(updated_path_names)
except ValueError:
    print('First time')
    FIRST_TIME = True
    backup_data = {'paths': updated_path_names}

dt = datetime.now()
dt = int(time.mktime(dt.timetuple()))
backup_data['date'] = dt

with open(JSON_FILE_LOCATION, 'w') as f:
    json.dump(backup_data, f, indent=4)
