# About
Date : 15th Apr 2021  
Author: Lionel Gurret  
Description : Configure an Ansible Lab with Docker and benchmark Mitogen and several optimizations ! (/!\ Don't use it on Production /!\)  
**Inspired by : https://github.com/goffinet and https://xavki.blog/** :)
# Prerequisites
This script is designed for Docker Playground !  
(https://labs.play-with-docker.com/)  
# How to run the lab
`git clone https://github.com/sokube/ansible-benchmark.git`  
`./build-images.sh`  
Edit run.sh script to specify the number of hosts you need for your Lab (NOF_HOSTS)  
`./run.sh`
Once you are on the container, please run :  
`./run-benchmark.sh`
