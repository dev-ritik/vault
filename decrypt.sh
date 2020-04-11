#!/bin/bash

DATA_PATH=/opt/vault
FILES_PATH=$DATA_PATH/files

OUTPUT_PATH=$pwd

declare -a BACKUP_PATH


if [ ! -f $INDEX_PATH ]; then
  echo "Index file not found!"
else
  if [ ! -d $FILES_PATH ];then
    echo "Files not found!"
  fi
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -b|--backup)
            nextArg="$2"
            while ! [[ "$nextArg" =~ -.* ]] && [[ $# > 1 ]]; do
                case $nextArg in
                    -o|--output)
                        echo "Please provide proper backup path"
                    ;;
                    *)
                        BACKUP_PATH+=("$nextArg")
                    ;;
                esac
                if ! [[ "$2" =~ -.* ]]; then
                    shift
                    nextArg="$2"
                else
                    shift
                    break
                fi
            done
        ;;
        -o|--output)
            nextArg="$2"
            while ! [[ "$nextArg" =~ -.* ]] && [[ $# > 1 ]]; do
                case $nextArg in
                    -b|--backup)
                        echo "Please provide proper output path"
                    ;;
                    *)
                        OUTPUT_PATH=$nextArg
                    ;;
                esac
                if ! [[ "$2" =~ -.* ]]; then
                    shift
                    nextArg="$2"
                else
                    shift
                    break
                fi
            done
        ;;
    esac
    shift
done

echo "Using ${BACKUP_PATH[*]} for picking backup files!"
echo "Using $OUTPUT_PATH as output path"

if [ -z "$BACKUP_PATH" ]; then
  echo "Provide files/directories to decrypt files from"
  exit 1
fi

declare -A items=()
while IFS= read -r -d '' key && IFS= read -r -d '' value; do
  items[$key]=$value
done < <(./decrypt.py "${BACKUP_PATH[@]}")

echo "Restoring "${#items[@]}" files"

for i in "${!items[@]}"
do
  echo $i :  ${items[$i]}
  mkdir -p $OUTPUT_PATH$(dirname $i)
  gpg --output $OUTPUT_PATH$i -d --batch --quiet --passphrase pass $FILES_PATH/${items[$i]}
done
