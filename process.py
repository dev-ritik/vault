#!/usr/bin/python3

import json
import os
import random
import string

DATA_PATH = os.environ["DATA_PATH"]

try:
    fd_in = os.fdopen(4, 'r')
    fd_out = os.fdopen(3, 'w')
    paths = fd_in.read().strip().split()
except OSError as e:
    raise AssertionError('Issue in file paths parsing')


def get_random_name():
    random_name = random.choices(string.ascii_letters + string.digits, k=8)
    random_name.append('.asc')
    return ''.join(random_name)


# home = expanduser("~")
JSON_FILE_LOCATION = os.path.join(DATA_PATH, 'index.json')
FIRST_TIME = False

if not os.path.isfile(JSON_FILE_LOCATION):
    raise AssertionError('Index file not found')

# Read index file
try:
    with open(JSON_FILE_LOCATION) as f:
        files_data = json.load(f)
except ValueError:
    FIRST_TIME = True
    files_data = {}

names = set()
path_name = dict()
new_path_name = dict()

# Check if these are new & get new/existing file name
if FIRST_TIME:
    for path in paths:
        new_name = get_random_name()
        while new_name in names:
            new_name = get_random_name()
        path_name[path] = new_name
        names.add(new_name)
    new_path_name = path_name
else:
    date_old = files_data['date']
    path_name = dict(files_data['paths'])
    names = set(path_name.values())

    for path in paths:
        if path in path_name.keys():
            # A file is updated
            name = path_name.get(path)
            new_path_name[path] = name
        else:
            # Its a new file
            new_name = get_random_name()
            while new_name in names:
                new_name = get_random_name()
            path_name[path] = new_name
            names.add(new_name)
            new_path_name[path] = new_name

# return new tuple list
for k in new_path_name:
    fd_out.write('%s\0%s\0' % (k, new_path_name[k]))
