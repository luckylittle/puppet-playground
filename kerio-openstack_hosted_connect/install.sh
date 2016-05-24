#!/bin/bash
# maly (c) 2013
# This script runs the basic steps for preparing to auto-deploy OpenStack as per Hosted Connect process
#
# This script: updates apt, and makes sure that the system is up to date with the current Ubuntu baseline
# It then downloads the current set of Puppet modules and a set of baseline manifests from the github repository
# If a proxy is necessary in order to download files from the internet, then either a proxy target can be passed to the script, or the environmet variables can be pre-set before running the script locally.

set -o errexit

usage() {
cat <<EOF
usage: $0 options

OPTIONS:
  -h           Show this message
  -p           http proxy i.e. -p http://username:password@host:port/
EOF
}

# wrapper all commands with sudo in case this is not run as root
# also map in a proxy in case it was passed as a command line argument
function run_cmd () {
  if [ -z "$PROXY" ]; then
    sudo $*
  else
    sudo env http_proxy=$PROXY https_proxy=$PROXY $*
  fi
}

# Define some useful APT parameters to make sure you get the latest versions of code

APT_CONFIG="-o Acquire::http::No-Cache=True -o Acquire::BrokenProxy=true -o Acquire::Retries=3"

# check if the environment is set up for http and https proxies
if [ -n "$http_proxy" ]; then
  if [ -z "$https_proxy" ]; then
    echo "Please set https_proxy env variable."
    exit 1
  fi
  PROXY=$http_proxy
fi

# parse CLI options
while getopts "h:p:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    p)
      PROXY=$OPTARG
      export http_proxy=$PROXY
      export https_proxy=$PROXY
  esac
done

# Make sure the apt repository list is up to date
echo -e "\n\nUpdate apt repository...\n\n"
if ! run_cmd apt-get $APT_CONFIG update; then
  echo "Can't update apt repository"
  exit 1
fi

# Install prerequisite packages
echo "Installing prerequisite apps: git, puppet, ipmitool..."
if ! run_cmd apt-get $APT_CONFIG install -qym git puppet ipmitool; then
  echo "Can't install prerequisites!..."
  exit 1
fi

# Grab the Puppet global manifests (site.pp, etc.), try to update a previously downloaded set first
echo "Cloning hosted-connect master branch from GIT..."
if [ -d /root/hosted-connect ] ; then
	echo -e "Looks like perhaps you ran this script before? We'll try to update your os-docs directory, just in case..."
	if ! run_cmd git --git-dir=/root/hosted-connect/.git/ pull ; then
	   echo "That did not work.  Perhaps rename your os-docs directory, and try again?"
	   exit 1
        fi
fi

# Get a new set, as there was no previous download
if [ ! -d /root/hosted-connect ] ; then
	if ! run_cmd git clone -b master https://github.com/luckylittle/hosted_connect /root/hosted-connect ; then
 	  echo "Can't run git clone!"
	  exit 1
	fi
fi

echo "Copying manifests to manifest dir..."
if ! run_cmd cp /root/hosted-connect/puppet/manifests/* /etc/puppet/manifests/ ;then
  echo "Can't copy manifests!!!"
  exit 1
fi

echo "Copying modules to modules dir..."
if ! run_cmd cp -r /root/hosted-connect/puppet/modules/* /etc/puppet/modules/ ;then
  echo "Can't copy modules!!!"
  exit 1
fi

mkdir -p /etc/puppet/files
echo "Copying files to files dir..."
if ! run_cmd cp -r /root/hosted-connect/puppet/files/* /etc/puppet/files/ ;then
  echo "Can't copy files!!!"
  exit 1
fi

# Update APT again, to capture any changes and updates driven by the newly loaded code
echo -e "\n\nUpdated apt repository...\n\n"
if ! run_cmd apt-get $APT_CONFIG update; then
  echo "Can't update apt repository"
  exit 1
fi

# Make sure the distro is up to date
echo -e "\n\nUpdate packages...\n\n"
if ! run_cmd apt-get $APT_CONFIG dist-upgrade -y; then
  echo "Can't update packages"
  exit 1
fi

echo -e "\n\nSUCCESS!!!!\n\n Now, you need to create file site.pp in /etc/puppet/manifests\n, and then run 'puppet apply -v /etc/puppet/manifests/site.pp"
echo -e "The file site.pp should contain 'import \"site-prod\"' or 'import \"site-lab\"'"

exit 0
