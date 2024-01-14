#!/bin/bash

set -euo pipefail


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_path output_path"
    exit 1
fi

input=$1
output=$2

/opt/drawio/drawio -x --crop -f pdf -o "${output}" "${input}" --no-sandbox --disable-gpu 2>&1 | grep -v "ERROR:bus.cc" | grep -v "Checking for" | grep -v "Found package-type"
