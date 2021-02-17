#!/usr/bin/python3

import json
import os

try:
    fd_in = os.fdopen(4, 'r')
    fd_out = os.fdopen(3, 'w')
    paths = fd_in.read().strip().split()
except OSError as e:
    raise AssertionError('Issue in file paths parsing')

DATA_PATH = os.environ["DATA_PATH"]
JSON_FILE_LOCATION = os.path.join(DATA_PATH, 'index.json')

if not os.path.isfile(JSON_FILE_LOCATION):
    raise AssertionError('Index file not found')

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
        fd_out.write('%s\0%s\0' % (k, restore_dict[k]))

except ValueError:
    raise AssertionError('No data found!')
