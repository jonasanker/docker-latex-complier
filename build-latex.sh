#!/bin/bash

docker build -t thesis .

# With Docker Volume for dependencies
docker volume create --name miktex
docker run --rm -v miktex:/miktex/.miktex/texmfs/install -v "$(pwd)":/output thesis