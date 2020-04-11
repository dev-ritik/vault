#!/usr/bin/python3

"""
Do not print anything!!
"""
import json
import os
import sys

paths = sys.argv[1:]
if len(paths) < 1:
    raise AssertionError('Invalid associated array')

DATA_PATH = '/opt/vault'
JSON_FILE_LOCATION = os.path.join(DATA_PATH, 'index.json')
FIRST_TIME = False

if not os.path.isfile(JSON_FILE_LOCATION):
    raise AssertionError('File not found')

# Read index file
try:
    with open(JSON_FILE_LOCATION) as f:
        backup_data = json.load(f)

    backed_paths = dict(backup_data['paths'])

    request_set = set(paths)
    # for path in paths:
    # request_set.update(set(glob.glob(path)))
    restore_dict = {}
    for request in request_set:
        selected_paths = list()
        if len(request) != 1 and request.endswith('/'):
            request = request[:-1]
        for path in backed_paths.keys():
            if path.startswith(request):
                selected_paths.append(path)
        for path in selected_paths:
            restore_dict[path] = backed_paths[path]
            backed_paths.pop(path)
    for k in restore_dict:
        sys.stdout.write('%s\0%s\0' % (k, restore_dict[k]))

except ValueError:
    raise AssertionError('No data found!')
