#!/usr/bin/env bash

echo "Add mesosphere key to local repository"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF 2>&1 >/dev/null

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
if [ ! -f .mesosphere_key_added ]; then
    echo "Add Mesosphere repository for ${DISTRO}/${CODENAME}"
    echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
    touch .mesosphere_key_added
fi
