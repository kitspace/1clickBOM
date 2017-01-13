#!/usr/bin/env bash
# watches for changes to the source or tasks to rebuild

# exit with non-zero code if anything fails
set -e

case "$OSTYPE" in
  solaris*) OS="SOLARIS" ;;
  darwin*)  OS="OSX" ;;
  linux*)   OS="LINUX" ;;
  bsd*)     OS="BSD" ;;
esac


build() {
    echo "ninja $1";
    ninja $1 && echo '* build succeeded *';
}

./configure.js && build $1;

if [ "$OS" == 'LINUX' ]; then
    while inotifywait --exclude '\..*sw.' -r -q -e modify src/; do
      build $1;
    done
elif [ "$OS" == 'OSX' ]; then
    while fswatch --one-event src/; do
      build $1;
    done
fi
