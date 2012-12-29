#!/bin/bash

. ../common.sh

InstallChef(){
 . /etc/profile.d/rvm.sh
 echo "Instaling chef form Gem"
 gem_ver_avail=`gem list chef | tr -s ")" " "| cut -d "(" -f2`
 is_set gem_ver_avail
 [[ $? -eq '' ]] && echo "chef gem version: $gem_ver_avail already installed continuing ..." || gem install chef
}

GenSoloConf(){

 test -d /etc/chef/ || mkdir -v /etc/chef/
 if [ -d /etc/chef/ ]; then
 [[ -f /etc/chef/solo.rb ]] && rm -f /etc/chef/solo.rb
cat >> /etc/chef/solo.rb << EOF
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
EOF
 fi
}


KickoffChefServer() {

if is_fedora; then 
 echo "The following action were designed for CentOS"
  AddRbelRepo

  is_package_installed rubygem-chef-server || install_package rubygem-chef-server
  test -f /usr/sbin/setup-chef-server.sh && rm -f `/usr/sbin/setup-chef-server.sh`
  is_package_installed rubygem-chef-server && ./rbel-chef-post-install.sh 
  if [ "$?" = "0" ]; then 
	 if [[ "$os_RELEASE" =~ "5.*" ]]; then
    	   echo "login to http://your-chef-server:4040 user: admin password: p@ssw0rd1"
    	   echo "Please note: this is the default passowrd change it !!!"
          elif [[ "$os_RELEASE" = "6" ]]; then
    	   echo "login to http://your-chef-server:4040 user: admin password: chef321go"
    	   echo "Please note: this passowrd was set by rbel repository change it !!!"
         fi
  fi
fi
}

BoootStrap
SetDefaultConf
GetOSVersion
InstallChef
GenSoloConf
KickoffChefServer
