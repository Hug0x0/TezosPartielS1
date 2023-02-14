#!/bin/sh

image=oxheadalpha/flextesa:20221123
script=limabox

docker run --rm --name sandbox --detach -p 20000:20000 \
    -e block_time=3 \
    -e flextesa_node_cors_origin='*' \
    "$image" "$script" start