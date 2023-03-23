#!/usr/bin/env bash

set -eu

# Install packages on startup
if [[ ! -d "lib" ]]; then
    pip install pillow -t lib
fi

if [ $# -eq 1 && $1 == "apply" ]; then
    terraform init
    terraform apply -auto-approve
fi

if [ $# -eq 0 || $1 != "apply" ]; then
    echo "No or invalid arguments supplied. Entering dev mode... "
    tail -f /dev/null
else
