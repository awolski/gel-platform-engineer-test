#!/usr/bin/env bash

set -eu

# Install packages on startup
if [[ ! -d "lib" ]]; then
    pip install pillow -t lib
fi

# If 'apply' provided, do terraform stuff
if [[ $# -eq 1 && $1 == "apply" ]]; then
    terraform init
    terraform apply -auto-approve
    exit 0
fi

# If 'destroy' provided, destroy terraform stuff
if [[ $# -eq 1 && $1 == "destroy" ]]; then
    terraform destroy -auto-approve
    exit 0
fi

# Othwerwise just leave the container running
echo "No or invalid arguments supplied. Entering dev mode... "
tail -f /dev/null
