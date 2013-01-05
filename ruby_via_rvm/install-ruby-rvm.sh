#!/bin/bash
. ../common.sh
[ -f ../config ] && ParseProps ../config || SetDefaultConf

InstallRubyDeps() {
	echo "installing ruby requirements for $os_VENDOR"
	if is_fedora; then
            for pkg in gcc-c++ patch readline readline-devel zlib \
	            zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 \
		    autoconf automake libtool bison; do
		is_package_installed $pkg || install_package $pkg
	    done
	
	elif is_ubuntu; then

	  for pkg in curl build-essential bison openssl libreadline5 \
		     libreadline-dev curl git-core zlib1g zlib1g-dev \
		     libssl-dev vim libsqlite3-0 libsqlite3-dev sqlite3 \
		     libreadline-dev libxml2-dev git-core subversion autoconf; do

	    is_package_installed $pkg || install_package $pkg

	  done

	fi
}

InstallRvm() {
	echo "Installing latest stable rvm"
	\curl -L https://get.rvm.io | sudo bash -s stable
}

InstallRuby() {
	echo "Setting ~/.gemrc defaults to --no-ri --no-rdoc"
	echo 'gem: --no-ri --no-rdoc' > ~/.gemrc
	echo "Installing ruby ${RUBY_VER} via rvm"
	echo RUBY_VER ::  ${RUBY_VER}
	$rvm_path/bin/rvm install ${RUBY_VER}
	rvm use ${RUBY_VER} --default
	echo "rvm use ${RUBY_VER} --default"
}


ValidateRuby() {
	. /etc/profile.d/rvm.sh
	rvm use ${RUBY_VER} --default &>/dev/null
	which ruby | grep rubies &>/dev/null || (echo "missing ruby in /usr/local/rvm/rubies/... " ; exit 2)
	ruby -v &>/dev/null && echo -e "Found `ruby -v`\n" || (echo "Couldn't find ruby exiting" ; exit 2)
	gem -v &>/dev/null && echo -e "Found rubygems `gem -v`\n" || (echo "Couldn't find rubygems exiting" ; exit 2)
	echo "In order to user rvn you will need to source /etc/profile.d/rvm.sh"
        echo "Validate rvm is used by executing \"which ruby\" - you should expect somthing like \"/usr/local/rvm/rubies/ruby-1.9.3-p362/bin/ruby\""
}

InstallVargrant() {
	. /etc/profile.d/rvm.sh
	gem install vagrant

	echo "What's Vagrant with out VirtualBox ?? "
	AddVirtualBoxRepo
	install_package VirtualBox-$VIRTUAL_BOX_VER
}

BoootStrap
if [ "$RVM_AVAIL" != "true" ]; then 
 InstallRubyDeps 
 InstallRvm
fi

InstallRuby
ValidateRuby

is_set VargrantInstall 
[[ "$?" -eq "0" ]] && InstallVargrant
