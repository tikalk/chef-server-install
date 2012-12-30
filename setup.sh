#!/bin/bash

. common.sh

__ruby_only() {
        pushd ./ruby_via_rvm && ./install-ruby-rvm.sh; popd &>/dev/null
}

__chef_server() {
        pushd ./chef_server && ./install_chef_server.sh; popd &>/dev/null
}

__usage() {
  printf "
 
Usage

  $0 {ruby | chef_server | vagrant | all | <internal usage: git>}
 
Options

  ruby		- installs ruby via rvm [ Curentelly installes latest stable ]
  chef_server	- Installes Chef Server [ Curentelly support CentOS 5 & 6 ] 
  all		- Installed both ruby & chef Server 
  vagrant	- BETA :: use at your own risk :) [now only works for me ... ]

Actions
 
  help 		- Display options (this output)
  git		- Ads git alias I find useful + warn if user.mame & user.email aren't set
 
"
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
        gitStuff
        ;;
  vagrant)
        export VargrantInstall=true	
	__ruby_only
	;;
  help|*)
        __usage
        exit 1
        ;;
esac


