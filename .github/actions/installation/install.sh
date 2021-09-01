VERSION=${1:-21.7.524}


wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get install update -y
sudo apt-get install puppet
