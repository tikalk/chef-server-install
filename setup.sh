#!/bin/bash

case "$1" in
  ruby_only)
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd
        ;;
  chef_server_only)
        pushd ./chef_server && ./install_chef_server.sh; popd
        ;;
  all)
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd
        pushd ./chef_server && ./install_chef_server.sh; popd
        ;;
  git)
        . common.sh
        gitStuff
        ;;
  *)
        echo $"Usage: $0 {ruby_only | chef_server_only | all | <internal usage: git>}"
        exit 1
        ;;
esac

