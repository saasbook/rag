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

cd hw
bundle install
./check_all_solutions

cd ..
cd rag
cd spec

# required to allow Oracle of Bacon grader to run ...
ln -s /home/ubuntu/hw/oracle-of-bacon/public/spec/graph_example.xml
ln -s /home/ubuntu/hw/oracle-of-bacon/public/spec/graph_example2.xml
ln -s /home/ubuntu/hw/oracle-of-bacon/public/spec/spellcheck_example.xml
ln -s /home/ubuntu/hw/oracle-of-bacon/public/spec/unauthorized_access.xml
ln -s /home/ubuntu/hw/oracle-of-bacon/public/spec/unknown.xml

