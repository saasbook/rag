#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 12.04 LTS EC2 instance

sudo apt-get install -y git
sudo apt-get install -y curl
\curl -L https://get.rvm.io | bash -s stable  --ruby=1.9.3
source ~/.rvm/scripts/rvm

git clone https://github.com/saasbook/rag.git

cd rag

bundle install
bundle exec rspec

cd ..
git clone https://github.com/saasbook/hw.git
