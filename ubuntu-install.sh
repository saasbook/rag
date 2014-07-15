#!/bin/bash
# Simple autograder setup script for configuring Ubuntu 14.04 LTS EC2 instance


SPORK_SCREEN=Spork
EDX_CLIENT_SCREEN=Edx-client
SCROLLBACK_DEFAULT=1000

USER_REPO=apelade
# The update_3218 branch is Spring2014 with hw_updates
RAG_BRANCH=devel_update #Spring2014
HW_BRANCH=devel_update #Spring2014
ROTTENPOTATOES_BRANCH=devel_update #hw3_solution
RUBYGEMS_VERSION=2.2.0
#clear



echo "
         Install Deployment Script for Saasbook to EC2
-------------------------------------------------------------------------------
"
if [ -z "$(echo $(screen -ls) | grep 'No Sockets')" ]; then
  echo "It seems some screen is running, you better check it out."
  screen -ls
  echo
  read -p  "Ctrl+c to exit! 'kill [pid pid]' or 'pkill -f SCREEN'"
fi
echo " General steps:
0. Get a copy of the old rag/config/autograders.yml and conf.yml for later.
1. Copy .screenrc and this file from rag to rag/.. and do 'source .screenrc'
2. Execute this script: ($0)
3. 'sudo chmod a+x $0' if execute permission denied.
4. Enter sudo password.
5. Enter github credentials, screen scrollback.
6. When prompted, copy over old config files and edit. Edit hw_testing_steps.rb paths.
7. When running, access with 'screen -r $SPORK_SCREEN' and 'screen -r $EDX_CLIENT_SCREEN'
8. If the script is re-run it shows errors but seems to be OK.
9. Check courseware is same queue and assignments as rag/config/autograder.yml
"
read -p "* Enter scrollback for screen. [$SCROLLBACK_DEFAULT]: " SCROLLBACK
SCROLLBACK="${SCROLLBACK:-$SCROLLBACK_DEFAULT}"
read -p "* Enter GitHub username for private repos: " GH_USER
read -s -p "* Enter GitHub password (will be hidden): " GH_PASS
#clear

INSTALL_ARGS="---------------------------------
Install to PWD: $PWD
RUBYGEMS_VERSION: $RUBYGEMS_VERSION
GH_USER: $GH_USER
GH_PASS: -secret-
USER_REPO: $USER_REPO
RAG_BRANCH: $RAG_BRANCH
HW_BRANCH: $HW_BRANCH
ROTTENPOTATOES_BRANCH: $ROTTENPOTATOES_BRANCH
SPORK_SCREEN: $SPORK_SCREEN
EDX_CLIENT_SCREEN: $EDX_CLIENT_SCREEN
SCROLLBACK: $SCROLLBACK
---------------------------------"
echo "

     Confirm install options:
     $INSTALL_ARGS
"
read -p "* If above info is correct, click Enter key to continue, or Ctrl+c to exit and edit $0 "





echo "
############################## Install Dependencies ###########################
"





sudo apt-get install -y git
sudo apt-get install -y curl

sudo -H -u ubuntu bash -c "\curl -L https://get.rvm.io | bash -s stable  --ruby=1.9.3"
source /home/ubuntu/.rvm/scripts/rvm
rvm --install use 1.9.3 && rvm rubygems --force $RUBYGEMS_VERSION
gem install therubyracer -v '0.9.10'
sudo apt-get install -y libxslt-dev libxml2-dev libpq-dev
source /home/ubuntu/.bash_profile



echo "
############################## Install Repositories ###########################
"
echo "
### Clone, install, and test rag.
"
git clone https://github.com/$USER_REPO/rag
cd rag
pwd
git checkout $RAG_BRANCH
git branch -a
bundle install
bundle exec rspec
bundle exec cucumber
cd ..

echo "
### Clone, install, and test hw.
"
git clone https://$GH_USER:$GH_PASS@github.com/$USER_REPO/hw
cd hw
git remote set-url origin https://github.com/$USER_REPO/hw
pwd
git checkout $HW_BRANCH
git branch -a
bundle install
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
git clone https://$GH_USER:$GH_PASS@github.com/$USER_REPO/rottenpotatoes.git
cd rottenpotatoes/
git remote set-url origin https://github.com/$USER_REPO/rottenpotatoes

pwd
git checkout $ROTTENPOTATOES_BRANCH
# TODO update not needed when Spring2014 branch gets updated Gemfile.lock
#git checkout -tb Spring2014 origin/Spring2014 #bundle update --source therubyracer
#bundle update --source therubyracer
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:test:prepare
cd ..

source /home/ubuntu/.bash_profile



#clear
echo "
#############################       Edit     ################################
"
echo "
### I will run nano thrice to install 2 files in rag/config and edit them,
### and to edit paths in hw/features/step_definitions/hw_testing_steps.rb
### Or you can quit now and edit the files offline because the only other
### thing left after this is running the screen commands from this file:
### $0 Line 187 or so.

* Click Enter key to continue, Ctrl+c to exit prematurely.
"
read -p "
* #1 Copy old rag/config/autograders.yml text to clipboard.
* Click Enter to open nano for the new file, paste in the text to nano.
* Save and close nano to continue.
"
nano rag/config/autograders.yml
#clear
read -p "
* #2 Do similar for rag/config/conf.yml. Click Enter to begin.
"
nano rag/config/conf.yml

read -p "
* Click Enter to edit HW_RAG_PATH and RAG_HW_PATH in hw_testing_steps.rb
* Using absolute paths is fine.
"
nano hw/features/step_definitions/hw_testing_steps.rb

read -p "
* Click Enter to run screens and finish.
"
echo "
#############################       Run        ################################
"

echo "
### Repeat bundle install and launch spork in rottenpotatoes repo.
Resume with: screen -r $SPORK_SCREEN
"
cd rottenpotatoes
pwd
screen -h $SCROLLBACK -dmS $SPORK_SCREEN bash -c\
 'gem -v; bundle install; bundle exec spork cucumber'
cd ..

echo "
### Repeat bundle install and launch run_edx_client.rb in rag repo.
Resume with: screen -r $EDX_CLIENT_SCREEN
"
cd rag
pwd
screen -h $SCROLLBACK -dmS $EDX_CLIENT_SCREEN bash -c\
 'source /home/ubuntu/.bash_profile; gem -v; bundle install; while true; do ./run_edx_client.rb live; done'
cd ..
#echo '
#Attempt to install git-aware bash prompt in ~/.bash_profile
#'
#echo '
#export PS1=$PS1\'\w\[\033[01;34m\]$(__git_ps1 " (%s)")${ret_status}$(~/.rvm/bin/rvm-prompt u) $(~/.rvm/bin/rvm-prompt g)\[\033[00m\]\' ' >> ~/.bash_profile
#source ~/.bash_profile

echo "
######################       Post-install        ##############################
"
screen -ls
echo "

Installed with args:
$INSTALL_ARGS

$0 done!

* Now do these:
* source ~/.bash_profile
* May need to do bundle install in each rottenpotatoes app
  incl rag/hw4_grader_stuff and 'rvm gemset use rag3' in hw/bdd-cucumber/public/rottenpotatoes
* Check courseware is same queue and assignments as
  in the recently modified ./rag/config/autograders.yml
* for migration grader (performance homework) a directory migration_grader will be required in the root, and inside the rjmHW6 branch of the https://github.com/saasbook/rottenpotatoes is required
"


