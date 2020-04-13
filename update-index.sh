#!/bin/bash

CONFIG_PATH=~/.config/vault
INCLUDED=$CONFIG_PATH/.include
EXCLUDED=$CONFIG_PATH/.exclude

DATA_PATH=/opt/vault
INDEX_PATH=$DATA_PATH/index.json
FILES_PATH=$DATA_PATH/files

if [ ! -f $INDEX_PATH ]; then
  echo "File not found!"
  touch $INDEX_PATH
  time="1234567890"
else
  time=$(sed -n '/    "date":/p'  $INDEX_PATH | sed -e 's/    "date": //' -e 's/,//')
  if [ -z "$time" ];then
    time="1234567890"
  fi
fi

included_lines=("$(tr '\n' ' ' < "$INCLUDED")")

if [ -z "$included_lines" ]; then
  echo "Edit $file to add some files paths to backup"
  exit 1
fi

mapfile -t excluded_lines < $EXCLUDED

excluded_lines=("${excluded_lines[@]/%/ -prune -o}")
excluded_lines=("${excluded_lines[@]/#/-path }")

#echo $time

readarray -d '' array < <(find $included_lines ${excluded_lines[*]} -type f -newermt @$(($time)) -print0)
echo "------------Found" ${#array[@]} " modified Files--------------"

declare -A items=()
while IFS= read -r -d '' key && IFS= read -r -d '' value; do
    items[$key]=$value
done < <(./process.py "${array[@]}")

#echo ${!items[*]}

echo "Encrypting Files"
for i in "${!items[@]}"
do
#  echo $i ${items[$i]}
  gpg --symmetric --cipher-algo AES128 --armor --batch --yes --passphrase pass --output $FILES_PATH/${items[$i]} "$i"
done
./update.py "$(declare -p items)"
