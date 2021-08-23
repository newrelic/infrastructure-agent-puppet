PUPPET_VERSION=${1:-5.5.0}
UBUNTU_DIST=${2:-buster}

sudo apt-get install update -y
sudo apt-get install git -y
wget https://apt.puppet.com/puppet${PUPPET_VERSION}-release-${UBUNTU_DIST}.deb
sudo dpkg -i puppet${PUPPET_VERSION}-release-${UBUNTU_DIST}.deb
sudo apt-get update -y
sudo apt-get install puppet
