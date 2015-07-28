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
    verbose curl -sSL https://rvm. io/mpapis.asc | verbose-short gpg --import -
    verbose curl -sSL https://get.rvm.io | verbose-short bash -s stable --quiet-curl --ruby=1.9.3
fi
verbose source ~/.rvm/scripts/rvm
# rag
verbose git-clone-ifmissing-cd https://github.com/saasbook/rag.git ~/rag
# To get a nice footer for screen for .screenrc
verbose cp -f ~/rag/.screenrc ~/.screenrc
#Take ssh key out of ENV hash and move to ./ssh.
verbose printenv GITHUB_DEPLOY_SSH_KEY > ~/.ssh/id_rsa
#Add required native extensions for ruby-filemagic gem
verbose sudo apt-get install libmagic-dev
verbose cd ~/rag/
#verbose rvm use 2.2.2 # for some reason, rvm doesn't automatically change ruby version from inside script
#verbose bundle-install-ifmissing

