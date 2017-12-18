#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

sudo apt-get -y install python-virtualenv
sudo apt-get -y install python3-pip
sudo apt-get -y install git


# On the root of your virtual machine, create a folder healthcheckapp
# The folder is only created if it does not exist
if [[ ! -d "healthcheckapp" ]];then
    mkdir -p ~/healthcheckapp
fi
# Change directory from the root and into the healthcheck app
cd ~/healthcheckapp

if [[ ! -d "hc-venv" && $valid_option = 2 ]];then
    virtualenv --python=python2 hc-venv
else
    virtualenv --python=python3 hc-venv
fi

VENV_ROOT=hc-venv/bin/activate
# Activate the virtual environment
source "${VENV_ROOT}"

if [[ ! -d "healthchecks" ]];then
# Clone the repo into the virtual machine
    git clone https://github.com/WinstonKamau/healthchecks.git
fi

# Install requirements for the machine
pip install -r healthchecks/requirements.txt
pip install mock

cd ~/healthcheckapp/healthchecks

# Use example local settings
cp hc/local_settings.py.example hc/local_settings.py

cd ~/healthcheckapp/healthchecks

# Run the migrate command
./manage.py makemigrations accounts admin api auth contenttypes payments sessions
./manage.py migrate

./manage.py test
