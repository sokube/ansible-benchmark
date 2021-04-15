#!/bin/bash

DIRECTORY=$PWD

echo "We are in : $DIRECTORY"
echo "Let's build our Ansible container image :"

cd $DIRECTORY/images && docker build -t ansible-controller:latest -f ansible-controller/Dockerfile .

cd $DIRECTORY
echo "We are in : $DIRECTORY"

echo "Now let's build our Ansible hosts containers image :"
cd $DIRECTORY/images && docker build -t centos-7-ansible-docker-host:latest -f centos-7-ansible-docker-host/Dockerfile .
