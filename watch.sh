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
    ninja && echo '* build succeeded *';
}

./configure.coffee && build;

if [ "$OS" == 'LINUX' ]; then
    while inotifywait --exclude '\..*sw.' -r -q -e modify src/; do
      build;
    done
elif [ "$OS" == 'OSX' ]; then
    while fswatch --one-event src/; do
      build;
    done
fi
