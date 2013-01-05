#!/bin/bash

. common.sh

__ruby_only() {
        pushd ./ruby_via_rvm &>/dev/null && ./install-ruby-rvm.sh; popd &>/dev/null
}

__chef_server() {
        pushd ./chef_server &>/dev/null && ./install_chef_server.sh; popd &>/dev/null
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

while [[ $# -gt 0 ]] ; do
  arg="$1" ; shift
  case "$arg" in
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
done

