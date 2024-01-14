#!/usr/bin/env bash

set -ex

# Install Python dependencies
pip3 install --user -r ./.devcontainer/requirements.txt

sudo cpanm -n -q Log::Log4perl
sudo cpanm -n -q XString
sudo cpanm -n -q Log::Dispatch::File
sudo cpanm -n -q YAML::Tiny
sudo cpanm -n -q File::HomeDir
sudo cpanm -n -q Unicode::GCString

npm install