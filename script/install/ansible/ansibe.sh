#!/bin/bash

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ $OS = "CentOS Linux" ]]; then
    echo $OS $VER
    sudo yum update -y
    sudo yum install epel-release -y
    sudo yum install ansible -y
elif [[ $OS = "Ubuntu Linux" ]]; then
    echo $OS $VER
    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install ansible
fi

mkdir /etc/ansible
mkdir ~/.ansible

cp ./hosts /etc/ansible/hosts
cp ./hosts ~/.ansible/hosts

cp -r ./templates ~/.ansible/templates

cp -r ./roles/geerlingguy.rabbitmq ~/.ansible/roles/geerlingguy.rabbitmq # Temp fix Erlang install for CentOS, will create pull request on official package.

rm -rf ./roles/geerlingguy.rabbitmq

service firewalld stop
systemctl disable firewalld.service

echo "Install Ansi"
ansible-galaxy install -r requirements.yml
ansible-playbook playbook.yml