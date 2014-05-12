#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 12.04 LTS EC2 instance

# TODO how to do this after clone of hw??? # copied ~/hide/rag/config/autograders.yml and conf.yml to rag/config
# 1. Copy this rag/spork.sh and this file from rag to rag/..
# 2. `sudo chmod a+x spork.sh ubuntu-install.sh` may be needed.
# 3. `./ubuntu-install.sh`
# 4. Enter sudo password.
# 5. Enter github credentials at clone of saasbook/hw and saasbook/rottenpotatoes, private repos.


################ Pre-install ##############

sudo apt-get install -y git
sudo apt-get install -y curl

\curl -L https://get.rvm.io | bash -s stable  --ruby=1.9.3
source ~/.rvm/scripts/rvm

# this needed for HW4 and must be installed before some other versions of libv8 are pulled in?
# We can get rid of it if we update HW3 and 4. It appears to fail if already installed, but tests pass.
gem install therubyracer -v '0.9.10'

sudo apt-get install libxslt-dev libxml2-dev



################ Repo Installs ##############

### Clone, install, and test rag.
git clone https://github.com/saasbook/rag.git
cd rag
# TODO read -p input for branch
git checkout Spring2014
git branch -a
bundle update --source ZenTest
bundle install
bundle exec rspec
bundle exec cucumber
cd ..


### Clone, install, and test hw.
git clone https://github.com/saasbook/hw.git
cd hw
git checkout Spring2014
git branch -a
bundle install
# This is moved to hw/features in develop
./check_all_solutions
cd ..
# Create a gemset in hw3 app
cd hw/bdd-cucumber/public/rottenpotatoes/

# This never comes back
#/bin/bash --login
rvm gemset create rag3 # there is an old already in repo, just update and use that?
mv rag3.gems rag3.gems.BAK
bundle install
rvm gemset export rag3
rvm gemset import rag3 # => failed unless export first
rvm gemset use rag3
cd ../../../..


### Clone, install, saasbook/rottenpotatoes hw3_solution branch. Test?
git clone https://github.com/saasbook/rottenpotatoes.git
cd rottenpotatoes/
pwd
git checkout -b hw3_solution origin/hw3_solution
#git checkout -tb Spring2014 origin/Spring2014
# not needed if Spring2014 branch has updated Gemfile.lock
# which will be needed to get rid of ruby-debug and or update beyond current 3.1.0
bundle update --source therubyracer 
#bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:test:prepare
cd ..


################     Run     ##############

### Start spork in another screen.
# TODO -h 999 lines of scrollback, -l login
#screen -dmS Spork
echo 'create screen for spork'
#screen -S Spork -p 0 -X exec ./spork.sh
cd rottenpotatoes
screen -dmS Spork bash -c 'bundle install; bundle exec spork cucumber'
cd ..


# TODO Copied manually! ~/hide/rag/config/autograders.yml and conf.yml to rag/config
echo
echo 'Prepare to lauch edx client loop:'
echo 'Copy your old rag/config/autograders.yml and conf.yml to rag/config and modify.'
echo
read -p '- CLICK ENTER TO CONTINUE WHEN DONE - '

### Start the Edx client loop rag/run_edx_client.rb in another screen.

cd rag
screen -dmS Edx-client bash -c 'bundle install; while true; do ./run_edx_client.rb live; done'
cd ..

echo "$0 exiting."

