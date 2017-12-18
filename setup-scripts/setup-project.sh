#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail

# Create the healthchecksapp directory if it does not exist
if [[ ! -d "healthchecksapp" ]];then
    mkdir -p ~/healthchecksapp
fi
# Change directory from the root and into the healthcheck app
cd ~/healthchecksapp

virtualenv --python=python3 hc-venv

VENV_ROOT=hc-venv/bin/activate
# Activate the virtual environment
source "${VENV_ROOT}"

if [[ ! -d "healthchecks-clone" ]];then
# Clone the repo into the virtual machine
    git clone https://github.com/Lemmah/healthchecks-clone.git
fi

# Install requirements for the machine
pip install -r healthchecks-clone/requirements.txt
pip install mock