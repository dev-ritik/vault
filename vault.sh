#!/bin/bash

CONFIG_PATH=~/.config/vault
INCLUDED=$CONFIG_PATH/.include
EXCLUDED=$CONFIG_PATH/.exclude

DATA_PATH=/opt/vault
INDEX_PATH=$DATA_PATH/index.json
FILES_PATH=$DATA_PATH/files

command -V gpg >/dev/null 2>&1 && GPG="gpg" || GPG="gpg2"
[ -z ${PASSWORD_STORE_DIR+x} ] && PASSWORD_STORE_DIR="$HOME/.password-store"
[ -r "$PASSWORD_STORE_DIR/.gpg-id" ] &&
  "$GPG" --list-secret-keys $(cat "$PASSWORD_STORE_DIR/.gpg-id") >/dev/null 2>&1 || {
  printf "\`pass\` must be installed and initialized to encrypt passwords.\\nBe sure it is installed and run \`pass init <yourgpgemail>\`.\\nIf you don't have a GPG public private key pair, run \`%s --full-gen-key\` first.\\n" "$GPG"
  exit 1
}

updateindex() {
  PASSWORD="$(pass vault)"
  if [ ! -f $INDEX_PATH ]; then
    echo "Index file not found, creating!"
    touch $INDEX_PATH
    time="1234567890"
  else
    time=$(sed -n '/    "date":/p' $INDEX_PATH | sed -e 's/    "date": //' -e 's/,//')
    if [ -z "$time" ]; then
      time="1234567890"
    fi
  fi

  included_lines=("$(tr '\n' ' ' <"$INCLUDED")")

  if [ -z "$included_lines" ]; then
    echo "Edit $file to add some files paths to backup"
    exit 1
  fi

  mapfile -t excluded_lines <$EXCLUDED

  excluded_lines=("${excluded_lines[@]/%/ -prune -o}")
  excluded_lines=("${excluded_lines[@]/#/-path }")

  #echo $time

  readarray -d '' array < <(find $included_lines ${excluded_lines[*]} -type f -newermt @$(($time)) -print0)
  echo "------------Found" ${#array[@]} " modified Files--------------"

  declare -A items=()
  while IFS= read -r -d '' key && IFS= read -r -d '' value; do
    items[$key]=$value
  done < <(./process.py "${array[@]}")

  # echo ${!items[*]}

  for i in "${!items[@]}"; do
    # echo $i ${items[$i]}
    "$GPG" --symmetric --cipher-algo AES128 --armor --batch --yes --passphrase $PASSWORD --output $FILES_PATH/${items[$i]} "$i"
  done
  ./update.py "$(declare -p items)"
}

decrypt() {
  PASSWORD="$(pass vault)"
  OUTPUT_PATH=$pwd

  declare -a BACKUP_PATH

  if [ ! -f $INDEX_PATH ]; then
    echo "Index file not found!"
  else
    if [ ! -d $FILES_PATH ]; then
      echo "Files not found!"
    fi
  fi

  while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
    -b | --backup)
      nextArg="$2"
      while ! [[ "$nextArg" =~ -.* ]] && [[ $# > 1 ]]; do
        case $nextArg in
        -o | --output)
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
    -o | --output)
      nextArg="$2"
      while ! [[ "$nextArg" =~ -.* ]] && [[ $# > 1 ]]; do
        case $nextArg in
        -b | --backup)
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
    -h | --help)
      display_help
      ;;
    *)
      echo "Wrong option!!"
      exit 1
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

  for i in "${!items[@]}"; do
    echo "$OUTPUT_PATH$i" : ${items[$i]}
    mkdir -p $OUTPUT_PATH$(dirname $i)
    "$GPG" --output "$OUTPUT_PATH$i" -d --batch --quiet --passphrase $PASSWORD $FILES_PATH/${items[$i]} || echo "Error occoured!!!"
  done
}

display_help() {
  echo "Usage: $0 [option...] {output|backup}" >&2
  echo
  echo "   -o, --output           Output path to restore files to (default pwd)"
  echo "   -b, --backup           Set of paths to restore files from"
  echo
  exit 1
}

case "$1" in
update) updateindex ;;
decrypt) decrypt "${@:2}" ;;
-f | --files) echo "Encrypted files are located at $DATA_PATH" ;;
*) cat <<EOF ;;

Vault encrypts-backs up the files included in $INCLUDED.
Password is stored in "pass vault"
Allowed options:
  update		Update the index and encrypt the files
  decrypt		Decrypt required files to a location
  files     Location of files stored available to be shared
  all else	Print this message
EOF
esac
