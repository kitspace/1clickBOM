#!/bin/bash

#exit with non-zero exit code if any process fails
set -e

# don't do anything on branch builds and pull-requests
if [ "${TRAVIS_BRANCH}" != "master" ] || [ "${TRAVIS_PULL_REQUEST}" != "false" ]
then
    exit 0
else
    sudo apt-get install pandoc
    git clean -xdf
    git branch gh-pages
    git fetch origin gh-pages
    git reset --hard origin/gh-pages
    make && make commit
    git push  "https://${GH_TOKEN}@github.com/monostable/1clickBOM" gh-pages:gh-pages > /dev/null 2>&1
fi
