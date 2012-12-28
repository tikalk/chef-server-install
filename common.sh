#!/bin/bash
set -e

set_default_conf() {
	RUBY_VER='1.9.3'
}

bootstrap() {
	[[ $(id -u) -ne "0" ]] && (echo "$0 [Cant execute]: $USER doesnt have permissions, \
	                      please re-run as root"; exit 1) || echo -e "User $USER /uid=$(id -u) validated, continuing ... \n"
	[[ -f config ]] && ( . config; echo "Sourced ./config" ) || (set_default_conf)
}

