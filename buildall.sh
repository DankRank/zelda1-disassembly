#!/bin/sh
set -x
./build.sh --quiet
./build.sh --quiet --rev1
./build.sh --quiet --ce
./build.sh --quiet --ac
./build.sh --quiet --vc
