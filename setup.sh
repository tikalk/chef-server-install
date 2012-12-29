#!/bin/bash

case "$1" in
  ruby_only)
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd
        ;;
  chef_server_only)
	pushd ./chef_server && ./install_chef_solo.sh; popd
	;;
  usage)
	echo $"Usage: $0 {ruby_only}"
	exit 1
	;;	
  *)
	pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd
	pushd ./chef_server && ./install_chef_solo.sh; popd
esac 


