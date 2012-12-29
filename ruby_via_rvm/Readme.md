1. Installing ruby
==================
	Option 1 - via rvm :: this is automated with the install-ruby-rvm.sh at the root of this repository 
	--------
	Install rvm [ just my prefernce you could install ruby from rpm too] the reason I like using rvm is that I can switch the system wide ruby version when ever I want, yes you could use alternatives for this too :) - as I said my personal preference], in this case we will be using root for multi-user rvm installation see: https://rvm.io/rvm/install for more info (worth noting this method adds /etc/profile.d/rvm.sh to your system)

	Installing system wide rvm (used for all users and placed under /usr/local/rvm)
		[root@hostname ~]# \curl -L https://get.rvm.io | sudo bash -s stable
		Please note the "\" before curl is to escape eny tweaking being done by your distro to curl

	Install CnetOS 5 ruby dependecies 
	(you can get this by typing 'rvm requirements' after installing rvm): 

		[]# yum install -y gcc-c++ patch readline readline-devel zlib \
				zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 \
				autoconf automake libtool bison

		[]# echo 'gem: --no-ri --no-rdoc' > ~/.gemrc
	*This option will just tell gem cmd to skip documentation

		
		[]# rvm install 1.9.3
		expected output:
			No binary rubies available for: downloads/ruby-1.9.3-p362.
			Continuing with compilation. Please read 'rvm mount' to get more information on binary rubies.
			Installing Ruby from source to: /usr/local/rvm/rubies/ruby-1.9.3-p362, this may take a while depending on your cpu(s)...
			ruby-1.9.3-p362 - #downloading ruby-1.9.3-p362, this may take a while depending on your connection...
			ruby-1.9.3-p362 - #extracting ruby-1.9.3-p362 to /usr/local/rvm/src/ruby-1.9.3-p362
			ruby-1.9.3-p362 - #extracted to /usr/local/rvm/src/ruby-1.9.3-p362
			ruby-1.9.3-p362 - #configuring
			ruby-1.9.3-p362 - #compiling
			ruby-1.9.3-p362 - #installing 
			Removing old Rubygems files...
			Installing rubygems-1.8.24 for ruby-1.9.3-p362 ...
			Installation of rubygems completed successfully.
			Saving wrappers to '/usr/local/rvm/bin'.
			ruby-1.9.3-p362 - #adjusting #shebangs for (gem irb erb ri rdoc testrb rake).
			...
			ruby-1.9.3-p362 - #importing default gemsets (/usr/local/rvm/gemsets/), this may take time ...
			Install of ruby-1.9.3-p362 - #complete 

		set ruby 1.9.3 to be the default ruby version:
		[]# rvm use 1.9.2 --default
        
        Just to duble check logout and login again and execute:
        []# which ruby; ruby -v; gem -v
        
        expected result:
        /usr/local/rvm/rubies/ruby-1.9.2-p320/bin/ruby
		ruby 1.9.2p320 (2012-04-20 revision 35421) [x86_64-linux]
		1.8.24


	Option 2 - via rpm
	--------
	For CentOs 5 add the following repository (for Ruby 1.8.7):
		curl  http://rpm.aegisco.com/aegisco/el5/aegisco.repo > /etc/yum.repos.d/aegisco.repo
		rpm -Uvh http://rbel.frameos.org/rbel5

	For CentOs 6 add the following repository:
		sudo rpm -Uvh http://rbel.frameos.org/rbel6

	Install rpms:
		[]# yum install -y ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow \ 
		gcc gcc-c++ automake autoconf make curl dmidecode

	Install gems from source (the aegisco repository provides gems version 1.6.2 ...)
		[]# curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
		[]# tar zxf rubygems-1.8.24.tgz && rm rubygems-1.8.24.tgz
		[]# cd rubygems-1.8.24 && ruby setup.rb --no-format-executable



	Option 3 - ruby & rubygems from source [I will let you experiment with this]
	--------
		Still need the yum deps listed earlier:
		[]# install -y gcc-c++ patch readline readline-devel zlib \
				zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 \
				autoconf automake libtool bison iconv-devel

	    []# cd /tmp
		[]# curl -O http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p320.tar.gz		
		[]# tar xvzf ruby-1.9.2-p320.tar.gz
		[]# cd ruby-1.9.2-p320
		[]# ./configure --prefix=/usr/local --enable-shared --disable-install-doc \
		     --with-opt-dir=/usr/local/lib --with-openssl-dir=/usr \
		     --with-readline-dir=/usr --with-zlib-dir=/usr
		[]# make && make install

		[]# curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
		[]# tar zxf rubygems-1.8.10.tgz
		[]# cd rubygems-1.8.10
		[]# sudo ruby setup.rb --no-format-executable

