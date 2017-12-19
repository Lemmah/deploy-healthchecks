#!/usr/bin/env bash

set -x
set -o errexit
set -o pipefail

# Use example local settings for db configs
cp hc/local_settings.py.example hc/local_settings.py

# Run the migrate command
python manage.py makemigrations accounts admin api auth contenttypes payments sessions
python manage.py migrate

