#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 14.04 LTS EC2 instance
SPORK_SCREEN=Spork
EDX_CLIENT_SCREEN=Edx-client

echo "
0. Get a copy of the old rag/config/autograders.yml and conf.yml for later.
1. Copy .screenrc and this file from rag to rag/.. and do 'source .screenrc'
2. './ubuntu-install.sh'
3. 'sudo chmod a+x ubuntu-install.sh' if execute permission denied.
4. Enter sudo password.
5. Enter github credentials at clone of saasbook/hw and saasbook/rottenpotatoes.
6. When prompted, after install of rag, copy over old config files and edit.
7. When running, access with 'screen -r $SPORK_SCREEN' and 'screen -r $EDX_CLIENT_SCREEN'
8. If the script is re-run it shows errors but seems to be OK.
9. If run multiple times, consider 'screen -r' and then 'Ctrl+a k' to kill them.
"
read -p "** Click Enter key to continue, Ctrl+c to exit.. "

echo "
############################## Install Dependencies ############################
"

sudo apt-get install -y git
sudo apt-get install -y curl

\curl -L https://get.rvm.io | bash -s stable  --ruby=1.9.3
source ~/.rvm/scripts/rvm

# this needed for HW4 and must be installed before some other versions of libv8 are pulled in?
# We can get rid of it if we update HW3 and 4. It appears to fail if already installed, but tests pass.
gem install therubyracer -v '0.9.10'

sudo apt-get install libxslt-dev libxml2-dev


echo "
############################## Install Repositories ############################
"
echo "
### Clone, install, and test rag.
"
git clone https://github.com/saasbook/rag.git
cd rag
git checkout Spring2014
git branch -a
bundle update --source ZenTest
bundle install
bundle exec rspec
bundle exec cucumber
cd ..

echo "
### Clone, install, and test hw.
"
git clone https://github.com/saasbook/hw.git
cd hw
git checkout Spring2014
git branch -a
bundle install
bundle exec rspec
# TODO update these when develop is merged, functionality moved to hw/features
#bundle exec cucumber # ./check_all_solutions
./check_all_solutions # bundle exec cucumber
cd ..
echo "
# Create and use a gemset in hw3 app
"
cd hw/bdd-cucumber/public/rottenpotatoes/
rvm gemset create rag3
mv rag3.gems rag3.gems.BAK
bundle install
rvm gemset export rag3
rvm gemset import rag3 # => failed unless export first
rvm gemset use rag3
cd ../../../..


echo "
### Clone, install, saasbook/rottenpotatoes hw3_solution branch.
"
git clone https://github.com/saasbook/rottenpotatoes.git
cd rottenpotatoes/
pwd
git checkout -b hw3_solution origin/hw3_solution
#git checkout -tb Spring2014 origin/Spring2014 #bundle update --source therubyracer 
# TODO update not needed if Spring2014 branch has updated Gemfile.lock
# which will be needed to get rid of ruby-debug and or update beyond current 3.1.0
bundle update --source therubyracer 
#bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:test:prepare
cd ..

echo "
#############################       Run        #################################
"
# TODO -h 999 lines of scrollback, -l login

echo "
### Repeat bundle install and launch spork in rottenpotatoes repo.
Resume with: screen -r $SPORK_SCREEN
"
cd rottenpotatoes
screen -dmS $SPORK_SCREEN bash -c 'bundle install; bundle exec spork cucumber'
cd ..


# TODO Copied manually! ~/hide/rag/config/autograders.yml and conf.yml to rag/config
echo "
** Now, copy old rag/config/autograders.yml and conf.yml to rag/config and modify.
Don't add them to source control.
"
read -p "** Click Enter key to continue when done." 
echo


echo "
### Repeat bundle install and launch run_edx_client.rb in rag repo.
Resume with: screen -r $EDX_CLIENT_SCREEN
"
cd rag
screen -dmS $EDX_CLIENT_SCREEN bash -c 'bundle install; while true; do ./run_edx_client.rb live; done'
cd ..


echo "
$0 done!
** Now, check courseware is same queue and assignments as rag/config/autograder.yml
"

