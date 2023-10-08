#!/bin/bash

sudo apt update -y
sudo apt install default-jre -y
java -version
sudo apt update -y 

wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
#wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
#sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt update -y 
sudo add-apt-repository universe -y 
sudo apt-get install jenkins -y 
sudo systemctl enable jenkins
sudo systemctl start jenkins 
sudo cat/var/lib/jenkins/secrets/initialAdminPassword