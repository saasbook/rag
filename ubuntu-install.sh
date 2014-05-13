#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 14.04 LTS EC2 instance
SPORK_SCREEN=Spork
EDX_CLIENT_SCREEN=Edx-client
RAG_BRANCH=Spring2014
HW_BRANCH=Spring2014
#TODO add Spring2014 branch for this repo too, and tag deploy on success
ROTTENPOTATOES_BRANCH=hw3_solution

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
10. Check courseware is same queue and assignments as rag/config/autograder.yml
"
read -p "* Click Enter key to continue, Ctrl+c to exit.. "
read -p "* GitHub username for private repos: " GH_USER
read -s -p "* GitHub password: " GH_PASS

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
pwd
git checkout $RAG_BRANCH
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
pwd
git checkout $HW_BRANCH
git branch -a
bundle install
bundle exec rspec
# TODO update these when develop is merged, functionality moved to hw/features
#bundle exec cucumber # ./check_all_solutions
./check_all_solutions # bundle exec cucumber
cd ..
echo "
### Create and use a gemset in hw3 app
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
#git checkout -b $ROTTENPOTATOES_BRANCH origin/$ROTTENPOTATOES_BRANCH
#This should be the same
git checkout $ROTTENPOTATOES_BRANCH
# TODO update not needed if Spring2014 branch has updated Gemfile.lock
# which will be needed to get rid of ruby-debug and or update beyond current 3.1.0
#git checkout -tb Spring2014 origin/Spring2014 #bundle update --source therubyracer
bundle update --source therubyracer
#bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:test:prepare
cd ..

echo "
#############################       Run        #################################
"

echo "
### Repeat bundle install and launch spork in rottenpotatoes repo.
Resume with: screen -r $SPORK_SCREEN
"
cd rottenpotatoes
pwd
screen -h 1000 -dmS $SPORK_SCREEN bash -c 'bundle install; bundle exec spork cucumber'
cd ..


# TODO Copied manually! ~/hide/rag/config/autograders.yml and conf.yml to rag/config
echo "
* Now, copy old rag/config/autograders.yml and conf.yml to rag/config and modify.
Don't add them to source control.
"
read -p "** Click Enter key to continue when done."


echo "
### Repeat bundle install and launch run_edx_client.rb in rag repo.
Resume with: screen -r $EDX_CLIENT_SCREEN
"
cd rag
pwd
screen -h 1000 -dmS $EDX_CLIENT_SCREEN bash -c 'bundle install; while true; do ./run_edx_client.rb live; done'
cd ..


echo "
$0 done!
* Now, check courseware is same queue and assignments as rag/config/autograder.yml
"

echo '
export PS1=$PS1\w\[\033[01;34m\]$(__git_ps1 " (%s)")${ret_status}$(~/.rvm/bin/rvm-prompt u) $(~/.rvm/bin/rvm-prompt g)\[\033[00m\] ' >> ~/.bash_profile

source ~/.bash_profile


