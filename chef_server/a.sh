#!/bin/bash
. ../common.sh

GetOSVersion 
echo "os_VENDOR: $os_VENDOR"
echo "os_RELEASE: $os_RELEASE"
echo "os_UPDATE: $os_UPDATE"
echo "os_PACKAGE: $os_PACKAGE"
echo "os_CODENAME: $os_CODENAME"

BOOTSTRAP_URL='http://s3.amazonaws.com/chef-solo/BoootStrap-latest.tar.gz'
BoootStrap
SetDefaultConf
GetOSVersion

InstallChef(){
 echo "Instaling chef form Gem"
 gem_ver_avail=`gem list chef | tr -s ")" " "| cut -d "(" -f2`
 is_set gem_ver_avail
 [[ $? -eq '' ]] && echo "chef gem version: $gem_ver_avail already installed continuing ..." || gem install chef
 test -d /etc/chef/ || mkdir -v /etc/chef/
}


is_fedora
AddEpelRepo
InstallChef
