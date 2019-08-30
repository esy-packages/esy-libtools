#! /bin/bash

mkdir -p test_dir

cd ./test_dir

echo '{"dependencies": {"libtools" : "esy-packages/esy-libtools:package.json#'$(git rev-parse --short HEAD)'"}}' > package.json

echo "ESY INSTALL"
esy install
echo "ESY BUILD"
esy build

esy x libtoolize --help

esy which libtoolize
esy x which libtoolize
