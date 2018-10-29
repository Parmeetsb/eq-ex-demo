#!/bin/bash

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install default-jdk jenkins  -y
sudo service jenkins restart

set +x
echo '**********************************************************'
echo '** Initial administration password to enter into browser:'
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
