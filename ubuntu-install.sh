#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 12.04 LTS EC2 instance

sudo apt-get install -y git

# ensure git branch names are on command prompt
# TODO

sudo apt-get install -y curl
\curl -L https://get.rvm.io | bash -s stable  --ruby=1.9.3
source ~/.rvm/scripts/rvm

# this needed for HW4 and must be installed before some other versions of libv8 are pulled in?
gem install therubyracer -v '0.9.10'

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

#
cd ../..

# To get a nice footer for screen for .screenrc

cp rag/.screenrc .screenrc

# to set up HW3 we must import the gemset
# this should be done in a second screen window

cd hw/bdd-cucumber/public/rottenpotatoes/
/bin/bash --login
rvm gemset create rag3
rvm gemset import rag3
rvm gemset use rag3

# also we need:

cd ~
sudo apt-get install libxslt-dev libxml2-dev
git clone https://github.com/saasbook/rottenpotatoes.git
cd rottenpotatoes/
git checkout -b hw3_solution origin/hw3_solution
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:test:prepare

# then the spork command can be run
bundle exec spork cucumber




