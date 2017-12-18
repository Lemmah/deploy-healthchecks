#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail

# Set up a python environment
sudo apt-get -y install python-virtualenv
sudo apt-get -y install python3-pip
sudo apt-get -y install git
