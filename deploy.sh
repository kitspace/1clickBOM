#!/bin/bash

#exit with non-zero exit code if any process fails
set -e

# don't do anything on branch builds and pull-requests
if [ "${TRAVIS_BRANCH}" != "master" ] || [ "${TRAVIS_PULL_REQUEST}" != "false" ]
then
    exit 0
else
    wget https://github.com/jgm/pandoc/releases/download/1.14/pandoc-1.14-1-amd64.deb
    sudo dpkg -i pandoc-1.14-1-amd64.deb
    git clone https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG} pages
    cd pages
    git config user.name "Travis CI"
    git config user.email "travisCI@monostable.co.uk"
    git checkout gh-pages
    make || exit 1
    make commit || exit 0 # allowed to fail if nothing to commit
    git push origin gh-pages
fi
