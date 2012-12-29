#!/bin/bash

. ../common.sh
#BOOTSTRAP_URL='http://s3.amazonaws.com/chef-solo/BoootStrap-latest.tar.gz'
BOOTSTRAP_URL='http://wiki.opscode.com/download/attachments/18645206/bootstrap-2012.06.26-epel-6-7.tar.gz?version=1&modificationDate=1340731435000'
BoootStrap
SetDefaultConf
GetOSVersion

InstallChef(){
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
 echo "The following action were desined for CentOS"
 echo "See: http://wiki.opscode.com/display/chef/Installing+Chef+Server+using+Chef+Solo#InstallingChefServerusingChefSolo-CentOS/RHELInstallationNotes for more details"

 echo "Disabeling selinux"
 lokkit --selinux=disabled # TBD find another method than lokkit ...

 echo "Stopping Iptables"
 service iptables stop

 AddEpelRepo
 is_package_installed gcc44 || install_package gcc44
 is_package_installed 'gcc44-c++' || install_package 'gcc44-c++'
 export CXX=`which g++44`
 export CC=`which gcc44`
 chef-solo -c /etc/chef/solo.rb -j ./chef$OS.json -r ${BOOTSTRAP_URL}

fi
}


InstallChef
GenSoloConf
KickoffChefServer
