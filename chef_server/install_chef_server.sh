#!/bin/bash

. ../common.sh
BOOTSTRAP_URL='http://s3.amazonaws.com/chef-solo/BoootStrap-latest.tar.gz'
#BOOTSTRAP_URL='http://wiki.opscode.com/download/attachments/18645206/bootstrap-2012.06.26-epel-6-7.tar.gz?version=1&modificationDate=1340731435000'
BoootStrap
SetDefaultConf
GetOSVersion

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
 echo "The following action were desined for CentOS"
# echo "See: http://wiki.opscode.com/display/chef/Installing+Chef+Server+using+Chef+Solo#InstallingChefServerusingChefSolo-CentOS/RHELInstallationNotes for more details"

# echo "Disabeling selinux"
# lokkit --selinux=disabled # TBD find another method than lokkit ...

# echo "Stopping Iptables"
# service iptables stop

# AddEpelRepo
# if [[ "$os_RELEASE" =~ "5.*" ]]; then 
#  is_package_installed gcc44 || install_package gcc44
#  is_package_installed 'gcc44-c++' || install_package 'gcc44-c++'
#  export CXX=`which g++44`
#  export CC=`which gcc44`
# fi

# echo "Adding gecode-devel as workaround for COOK-528 see: http://tickets.opscode.com/browse/COOK-528"
# AddAegiscoRepo
# is_package_installed gecode-devel || yum -y install gecode-devel
# [[ -L /usr/local/lib/libgecodekernel.so ]] && rm -f /usr/local/lib/libgecodekernel.so
# test -L /usr/lib64/libgecodekernel.so || ln -s /usr/lib64/libgecodekernel.so /usr/local/lib/libgecodekernel.so
 
# chef-solo -c /etc/chef/solo.rb -j ./chef$OS.json -r ${BOOTSTRAP_URL}
  AddRbelRepo
  is_package_installed rubygem-chef-server || install_package rubygem-chef-server
  is_package_installed rubygem-chef-server && setup-chef-server.sh 

fi
}


InstallChef
GenSoloConf
KickoffChefServer
