#!/bin/bash -x
set -e

SetDefaultConf() {
echo "This function was called if no config file was present in project root dir"

export RUBY_VER='1.9.3'
export VIRTUAL_BOX_VER='4.2'
# URLS
export aegisco_url='http://rpm.aegisco.com/aegisco/el5/aegisco.repo'
}

ParseProps() {

        [[ "$1" != ""  ]] && local PROP_FILE=$1
        [[ -f $PROP_FILE ]] && (echo "Parsing  $PROP_FILE") || (echo "Property file not found: $PROP_FILE")

        while read line; do
          echo "$line" | grep "^#" >/dev/null
          if [ $? -ne 0 ] && echo $line |grep "=" 1>/dev/null ; then
            key=`echo $line |cut -f1 -d=`
            val=`grep "^$key=" $PROP_FILE`
            echo "$key" | grep [/.] > /dev/null
            if [ "$?" -ne "0" ] ; then
              export $val
              echo $val
            fi
          fi
        done  < $PROP_FILE
}


BoootStrap() {

	if [ $(id -u) -ne "0" ]; then 
	  echo "$0 [Can't execute]: $USER doesnt have permissions, \
	     please re-run as root"
	  [[ is_ubuntu ]] && echo -e "\nsudo -i should do the trick :)\n"
	  exit 1 
	else
	 echo -e "User $USER /uid=$(id -u) validated, continuing ... \n"
	fi

	[[ -f /etc/profile.d/rvm.sh ]] && ( . /etc/profile.d/rvm.sh; echo "Sourcing rvm environmet" )  || (echo "rvm not present yet ...")

}

GetOSVersion() {

    if [[ -n "`which sw_vers 2>/dev/null`" ]]; then

        os_VENDOR=`sw_vers -productName`
        os_RELEASE=`sw_vers -productVersion`
        os_UPDATE=${os_RELEASE##*.}
        os_RELEASE=${os_RELEASE%.*}
        os_PACKAGE=""
        if [[ "$os_RELEASE" =~ "10.7" ]]; then
            os_CODENAME="lion"
        elif [[ "$os_RELEASE" =~ "10.6" ]]; then
            os_CODENAME="snow leopard"
        elif [[ "$os_RELEASE" =~ "10.5" ]]; then
            os_CODENAME="leopard"
        elif [[ "$os_RELEASE" =~ "10.4" ]]; then
            os_CODENAME="tiger"
        elif [[ "$os_RELEASE" =~ "10.3" ]]; then
            os_CODENAME="panther"
        else
            os_CODENAME=""
        fi
    elif [[ -x $(which lsb_release 2>/dev/null) ]]; then
        os_VENDOR=$(lsb_release -i -s)
        os_RELEASE=$(lsb_release -r -s)
        os_UPDATE=""
        if [[ "Debian,Ubuntu" =~ $os_VENDOR ]]; then
            os_PACKAGE="deb"
        elif [[ "SUSE LINUX" =~ $os_VENDOR ]]; then
            lsb_release -d -s | grep -q openSUSE
            if [[ $? -eq 0 ]]; then
                os_VENDOR="openSUSE"
            fi
            os_PACKAGE="rpm"
        else
            os_PACKAGE="rpm"
        fi
        os_CODENAME=$(lsb_release -c -s)
    elif [[ -r /etc/redhat-release ]]; then
        os_CODENAME=""
        for r in "Red Hat" CentOS Fedora; do
            os_VENDOR=$r
            if [[ -n "`grep \"$r\" /etc/redhat-release`" ]]; then
                ver=`sed -e 's/^.* \(.*\) (\(.*\)).*$/\1\|\2/' /etc/redhat-release`
                os_CODENAME=${ver#*|}
                os_RELEASE=${ver%|*}
                os_UPDATE=${os_RELEASE##*.}
                os_RELEASE=${os_RELEASE%.*}
                break
            fi
            os_VENDOR=""
        done
        os_PACKAGE="rpm"
    elif [[ -r /etc/SuSE-release ]]; then
        for r in openSUSE "SUSE Linux"; do
            if [[ "$r" = "SUSE Linux" ]]; then
                os_VENDOR="SUSE LINUX"
            else
                os_VENDOR=$r
            fi

            if [[ -n "`grep \"$r\" /etc/SuSE-release`" ]]; then
                os_CODENAME=`grep "CODENAME = " /etc/SuSE-release | sed 's:.* = ::g'`
                os_RELEASE=`grep "VERSION = " /etc/SuSE-release | sed 's:.* = ::g'`
                os_UPDATE=`grep "PATCHLEVEL = " /etc/SuSE-release | sed 's:.* = ::g'`
                break
            fi
            os_VENDOR=""
        done
        os_PACKAGE="rpm"
    fi
    export os_VENDOR os_RELEASE os_UPDATE os_PACKAGE os_CODENAME
}

function GetDistro() {
    GetOSVersion
    if [[ "$os_VENDOR" =~ (Ubuntu) ]]; then
        DISTRO=$os_CODENAME
    elif [[ "$os_VENDOR" =~ (Fedora) ]]; then
        DISTRO="f$os_RELEASE"
    elif [[ "$os_VENDOR" =~ (openSUSE) ]]; then
        DISTRO="opensuse-$os_RELEASE"
    elif [[ "$os_VENDOR" =~ (SUSE LINUX) ]]; then

        if [[ -z "$os_UPDATE" ]]; then
            DISTRO="sle${os_RELEASE}"
        else
            DISTRO="sle${os_RELEASE}sp${os_UPDATE}"
        fi
    else

        DISTRO="$os_VENDOR-$os_RELEASE.$os_UPDATE"
    fi
    export DISTRO
}

function exit_distro_not_supported {
    if [[ -z "$DISTRO" ]]; then
        GetDistro
    fi

    if [ $# -gt 0 ]; then
        echo "Support for $DISTRO is incomplete: no support for $@"
    else
        echo "Support for $DISTRO is incomplete."
    fi

    exit 1
}


function is_suse {
    if [[ -z "$os_VENDOR" ]]; then
        GetOSVersion
    fi

    [ "$os_VENDOR" = "openSUSE" ] || [ "$os_VENDOR" = "SUSE LINUX" ]
}


function is_fedora {
    if [[ -z "$os_VENDOR" ]]; then
        GetOSVersion
    fi

    [ "$os_VENDOR" = "Fedora" ] || [ "$os_VENDOR" = "Red Hat" ] || [ "$os_VENDOR" = "CentOS" ]
}

function is_ubuntu {
    if [[ -z "$os_PACKAGE" ]]; then
        GetOSVersion
    fi

    [ "$os_PACKAGE" = "deb" ]
}

function yum_install() {
    [[ "$OFFLINE" = "True" ]] && return
    local sudo="sudo"
    [[ "$(id -u)" = "0" ]] && sudo="env"
    $sudo http_proxy=$http_proxy https_proxy=$https_proxy \
        no_proxy=$no_proxy \
        yum install -y "$@"
}

function apt_get() {
    [[ "$OFFLINE" = "True" || -z "$@" ]] && return
    local sudo="sudo"
    [[ "$(id -u)" = "0" ]] && sudo="env"
    $sudo DEBIAN_FRONTEND=noninteractive \
        http_proxy=$http_proxy https_proxy=$https_proxy \
        no_proxy=$no_proxy \
        apt-get --option "Dpkg::Options::=--force-confold" --assume-yes "$@"
}

function zypper_install() {
    [[ "$OFFLINE" = "True" ]] && return
    local sudo="sudo"
    [[ "$(id -u)" = "0" ]] && sudo="env"
    $sudo http_proxy=$http_proxy https_proxy=$https_proxy \
        zypper --non-interactive install --auto-agree-with-licenses "$@"
}


function install_package() {
    if is_ubuntu; then
        [[ "$NO_UPDATE_REPOS" = "True" ]] || apt_get update
        NO_UPDATE_REPOS=True

        apt_get install "$@"
    elif is_fedora; then
        yum_install "$@"
    elif is_suse; then
        zypper_install "$@"
    else
        exit_distro_not_supported "installing packages"
    fi
}

function is_package_installed() {
    if [[ -z "$@" ]]; then
        return 1
    fi

    if [[ -z "$os_PACKAGE" ]]; then
        GetOSVersion
    fi

    if [[ "$os_PACKAGE" = "deb" ]]; then
        dpkg -l | grep "$@" > /dev/null
        return $?
    elif [[ "$os_PACKAGE" = "rpm" ]]; then
        rpm --quiet -q "$@"
        return $?
    else
        exit_distro_not_supported "finding if a package is installed"
    fi
}

function is_set() {
    local var=\$"$1"
    if eval "[ -z \"$var\" ]"; then
        return 1
    fi
    return 0
}

# End of contrib

AddEpelRepo() {
    if is_fedora; then
      if [ -f /etc/yum.repos.d/epel.repo ]; then
	 #see if enabled ...
	 cat /etc/yum.repos.d/epel.repo | grep enabled=1 | head -1 && echo "EPEL repository found in /etc/yum.repos.d/epel.repo"
      else
	echo "enabeling EPEL repo"
	if [[ "$os_RELEASE" =~ "5.*" ]]; then
	   epel_rpm_url="http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm"

	elif [[ "$os_RELEASE" = "6" ]]; then
	   epel_rpm_url="http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
        fi 
	epel_rpm=`echo $epel_rpm_url | cut -d "/" -f 8`
        epel_pkg_name=`echo $epel_rpm | cut -d "-" -f 1,2`
	#echo epel_rpm: $epel_rpm epel_pkg_name: $epel_pkg_name
        is_package_installed $epel_pkg_name
	if [ "$?" != "0" ]; then
	  echo downloading $epel_rpm
	  \curl -O $epel_rpm_url
          yum -y install $epel_rpm	
	fi
      fi	
   fi
}

AddAegiscoRepo() {
 if [ ! -f /etc/yum.repos.d/aegisco.repo ]; then
   \curl --silent --output /etc/yum.repos.d/aegisco.repo $aegisco_url
 fi
 return $?
}

AddRbelRepo() {

    if is_fedora; then
        if [[ "$os_RELEASE" =~ "5.*" ]]; then
           rbel_rpm_url='http://rbel.frameos.org/rbel5'

        elif [[ "$os_RELEASE" = "6" ]]; then
           rbel_rpm_url='http://rbel.frameos.org/rbel6'
        fi
        rbel_rpm=`echo $rbel_rpm_url | cut -d "/" -f 4`
        is_package_installed $rbel_rpm-release || rpm -Uvh $rbel_rpm_url
    fi

}

AddOpsCodeRepo() {
	[[ ! -f /etc/apt/sources.list.d/opscode.list ]] && (echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list) 

	if [ ! -f /etc/apt/trusted.gpg.d/opscode-keyring.gpg ]; then
	  mkdir -p /etc/apt/trusted.gpg.d
	  gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
	  gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
	fi
}

AddVirtualBoxRepo() {

if is_fedora; then
   [[ ! -f /etc/yum.repos.d/virtualbox.repo  ]] && wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
elif is_ubuntu; then
   cat /etc/apt/sources.list | grep virtualbox
   if [ "$? " != "0" ]; then
     if [ `lsb_release -cs` = "precise" ] || [ `lsb_release -cs` =  "oneiric" ] || \
        [ `lsb_release -cs` =  "natty" ] ||  [ `lsb_release -cs` = "wheezy" ]   || [ `lsb_release -cs` = "quantal" ] ; then
          non_free='contrib'
     else
        non_free='contrib non-free'
     fi
     [[ ! -f /etc/apt/sources.list.d/virtualbox.list ]] && (echo "deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` $non_free" | sudo tee /etc/apt/sources.list.d/virtualbox.list )
     wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add - &>/dev/null
   else
     echo "Looks like virtualbox repo is in yout source.list" `cat /etc/apt/sources.list | grep virtualbox`
   fi

fi
}



gitStuff() {

        #Add common <to me> git aliases 
        git config alias.st status
        git config alias.ci commit
        git config alias.br branch
        git config alias.co checkout
        git config alias.df diff
        git config alias.lg 'log -p'

        # Check local conifg - annoying to see commit on git hub with user@localhost ...
        (git config --get user.email &>/dev/null || git config --get user.name &>/dev/null ) || \
        (echo -e "Git config seems empty I would do the following:" 
        echo -e "\t git config user.name \"Your username\"" 
        echo -e "\t git config user.email youremail@exmaple.com \n")

        # Show what you did ...
        echo -e "This just addedd the following git aliases to your repository ::\n"
        git config --get-regexp alias

}


WhereAmI_old() { 
SCRIPT_NAME="${0##*/}"
SCRIPT_DIR="${0%/*}"

# if the script was started from the base directory, then the 
# expansion returns a period
if test "$SCRIPT_DIR" == "." ; then
  SCRIPT_DIR="$PWD"
# if the script was not called with an absolute path, then we need to add the 
# current working directory to the relative path of the script
elif test "${SCRIPT_DIR:0:1}" != "/" ; then
  SCRIPT_DIR="$PWD/$SCRIPT_DIR"
fi
echo SCRIPT_NAME :: $SCRIPT_NAME
echo SCRIPT_DIR :: $SCRIPT_DIR
}

