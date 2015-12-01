#!/bin/bash
# Simple autograder setup.sh for configuring Ubuntu 12.04 LTS EC2 instance
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
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  # turn off ssh host checking for scripting.
verbose sudo apt-get install -y git curl
if ! test -e ~/.rvm/scripts/rvm; then
    verbose curl -sSL https://rvm.io/mpapis.asc | verbose-short gpg --import -
    verbose curl -sSL https://get.rvm.io | verbose-short bash -s stable --quiet-curl --ruby=2.2.2
fi
verbose git-clone-ifmissing-cd https://github.com/saasbook/rag.git /home/ubuntu/rag/
# To get a nice footer for screen for .screenrc
verbose cp -f /home/ubuntu/rag/.screenrc /home/ubuntu/.screenrc
#Take ssh key out of ENV hash and move to ./ssh.
verbose cat $ssh_key > /home/ubuntu/.ssh/id_rsa
verbose sudo chmod 0600 /home/ubuntu/.ssh/id_rsa
verbose source /home/ubuntu/.rvm/scripts/rvm
verbose cd /home/ubuntu/rag/
verbose git checkout autograder_engine_refactor
verbose rvm use 2.2.2 # for some reason, rvm doesn't automatically change ruby version from inside script
verbose gem install bundler
verbose bundle-install-ifmissing
