# Install pdk
wget https://apt.puppet.com/puppet-tools-release-focal.deb
sudo dpkg -i puppet-tools-release-focal.deb
sudo apt-get update
sudo apt-get install pdk

#Verify is forge api key is assigned, if not exit
if [ -z "$FORGE_API_KEY" ]; then
    echo "FORGE_API_KEY not set, exiting..."
    exit 1
fi

#Publish module
pdk release --force --forge-token=$FORGE_API_KEY --skip-changelog --skip-validation --skip-documentation


