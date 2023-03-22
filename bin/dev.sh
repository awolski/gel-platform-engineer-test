#!/usr/bin/env bash

set -eu

# Install packages on startup
if [[ ! -d "lib" ]]; then
    pip install pillow -t lib
fi

tail -f /dev/null
