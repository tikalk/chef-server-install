#!/bin/bash

__ruby_only() {
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd &>/dev/null
}

__chef_server() {
        pushd ./chef_server && ./install_chef_server.sh; popd &>/dev/null
}

case "$1" in
  ruby)
	__ruby_only
        ;;
  chef_server)
	__chef_server
        ;;
  all)
	__ruby_only
	__chef_server
        ;;
  git)
        . common.sh
        gitStuff
        ;;
  *)
        echo $"Usage: $0 {ruby | chef_server | all | <internal usage: git>}"
        exit 1
        ;;
esac

