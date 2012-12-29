#!/bin/bash

. ../common.sh

InstallRvm() {
	echo "Installing latest stable rvm"
	\curl -L https://get.rvm.io | sudo bash -s stable
}

InstallRubyDeps() {
	if is_fedora; then
	echo "installing ruby requirements"
	yum install -y gcc-c++ patch readline readline-devel zlib \
	zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 \
	autoconf automake libtool bison
	elif is_ubuntu; then
		echo "Do ubutnu stuff ..."
	fi
}

InstallRuby() {
	echo "Setting ~/.gemrc defaults to --no-ri --no-rdoc"
	echo 'gem: --no-ri --no-rdoc' > ~/.gemrc
	. /etc/profile.d/rvm.sh
	echo "Installing ruby ${RUBY_VER} via rvm"
	$rvm_path/bin/rvm install ${RUBY_VER}
	rvm use ${RUBY_VER} --default
	echo "rvm use ${RUBY_VER} --default"
}


ValidateRuby() {
	. /etc/profile.d/rvm.sh
	rvm use ${RUBY_VER} --default &>/dev/null
	which ruby | grep rubies &>/dev/null || (echo "missing ruby in /usr/local/rvm/rubies/... " ; exit 2)
	ruby -v &>/dev/null && echo -e "Found `ruby -v`\n" || (echo "Couldn't find ruby exiting" ; exit 2)
	gem -v &>/dev/null && echo -e "Found rubygems `gem -v` found\n" || (echo "Couldn't find rubygems exiting" ; exit 2)
}

BoootStrap
SetDefaultConf
InstallRvm
InstallRubyDeps
InstallRuby
ValidateRuby
