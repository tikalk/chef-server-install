#!/bin/bash

case "$1" in
  ruby_only)
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd
        ;;
  *)
        echo $"Usage: $0 {ruby_only}"
        exit 1

esac 

