#!/usr/bin/env bash
set -e
if [ "$1" == 'run' ]; then
    jpm run --addon-dir $(pwd)/build/firefox --binary $(which firefox);
elif [ "$1" == 'post' ]; then
    jpm post --addon-dir $(pwd)/build/firefox --binary $(which firefox) \
            --post-url http://localhost:8888;
else
    echo "USAGE ./firefox.sh [ run | post ]";
    exit 1;
fi
