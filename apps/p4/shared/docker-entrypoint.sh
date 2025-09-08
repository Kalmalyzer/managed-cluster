#!/bin/bash

set -euo pipefail

# If this is the first launch of the server, initialize it
if ! p4d  -C1 -xD; then
    p4d  -C1 -xD $P4NAME
    p4d  -C1 -Gc
fi

# Run the server
p4d -C1
