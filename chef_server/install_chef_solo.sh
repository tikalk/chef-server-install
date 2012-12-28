#!/bin/bash

. ../common.sh

bootstrap
set_default_conf


install_chef(){
echo "Instaling chef form Gem"
gem install chef

#echo -e "Creating chef configuration directory \n"
mkdir -v /etc/chef/
}


create_solo_conf(){

test -d /etc/chef/

if [ -d /etc/chef/ ]; then

cat >> /etc/chef/solo.rb << EOF
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
EOF
fi
}


bootstrap_chef_server() {
chef-solo -c /etc/chef/solo.rb -j ./chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz
}
