#!/bin/bash

CONFIG_PATH=~/.config/vault
DATA_PATH=~/.local/share/vault

mkdir -p $CONFIG_PATH
sudo mkdir -p $DATA_PATH

sudo chown -R "$USER":"$USER" $DATA_PATH

touch $CONFIG_PATH/.targets

mkdir -p $DATA_PATH/files
touch $DATA_PATH/index.json
