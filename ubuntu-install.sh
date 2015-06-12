#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 12.04 LTS EC2 instance

set -e

# get clone only if missing, then cd into it
git-clone-ifmissing-cd() {
    if ! test -e "$2"; then
        verbose-short git clone "$1" "$2"
    fi
    verbose-short cd "$2"
}

# gem install only if not installed
gem-install-ifmissing() {
  if ! gem list -i $@ > /dev/null; then
    verbose-short gem install $@ --no-doc
  fi
}

# bundle install only if not installed
bundle-install-ifmissing() {
  if ! bundle check > /dev/null; then
    verbose-short bundle install
  fi
}

# Prepend `verbose` to any command to have it echoed as well as run.
verbose() {
  echo 1>&2 ' '
  echo 1>&2 $ $@
  $@
}

verbose-short() {
  echo 1>&2 $ $@
  $@
}

# install things
verbose sudo apt-get install -y git curl
if ! test -e ~/.rvm/scripts/rvm; then
    verbose curl -sSL https://rvm.io/mpapis.asc | verbose-short gpg --import -
    verbose curl -sSL https://get.rvm.io | verbose-short bash -s stable --quiet-curl --ruby=1.9.3
    # --rubygems=2.1.11 is for ZenTest in ~/rag
fi
verbose source ~/.rvm/scripts/rvm
verbose rvm rubygems 2.1.11 --force
# this needed for HW4 and must be installed before some other versions of libv8 are pulled in?
verbose gem-install-ifmissing therubyracer -v '0.9.10'

# rag
verbose git-clone-ifmissing-cd https://github.com/saasbook/rag.git ~/rag
verbose gem-install-ifmissing ruby-debug19  # http://stackoverflow.com/a/21466030/782045
verbose bundle-install-ifmissing
# There used to be an issue with the above command. Here are solutions that
# didn't seem to work:
# https://github.com/seattlerb/zentest/issues/48
# http://stackoverflow.com/a/23810004/782045
# gem install debugger -v '1.6.2' --no-doc
verbose bundle exec rspec --format progress --out /dev/null

# hw
verbose git-clone-ifmissing-cd https://github.com/saasbook/hw.git ~/hw
verbose bundle-install-ifmissing
verbose ./check_all_solutions.sh

# required to allow Oracle of Bacon grader to run ...
verbose \
ln -sf ~/hw/oracle-of-bacon/public/spec/graph_example.xml \
       ~/hw/oracle-of-bacon/public/spec/graph_example2.xml \
       ~/hw/oracle-of-bacon/public/spec/spellcheck_example.xml \
       ~/hw/oracle-of-bacon/public/spec/unauthorized_access.xml \
       ~/hw/oracle-of-bacon/public/spec/unknown.xml \
       ~/rag/spec

# To get a nice footer for screen for .screenrc
verbose cp -f ~/rag/.screenrc ~/.screenrc

# to set up HW3 we must import the gemset
# this should be done in a second screen window
verbose cd ~/hw/bdd-cucumber/public/rottenpotatoes/
# /bin/bash --login
verbose rvm gemset create rag3
verbose rvm gemset import rag3
verbose rvm gemset use rag3

# rottenpotatoes
verbose sudo apt-get install -y libxslt-dev libxml2-dev
verbose git-clone-ifmissing-cd https://github.com/saasbook/rottenpotatoes.git ~/rottenpotatoes
verbose git checkout hw3_solution
verbose bundle-install-ifmissing
verbose bundle exec rake db:create
verbose bundle exec rake db:migrate
verbose bundle exec rake db:test:prepare
# then the spork command can be run
# verbose bundle exec spork cucumber
