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

#Set variables
url='https://forgeapi.puppet.com/v3/releases'
metadata=$(cat metadata.json)
release_name=$(echo "$metadata" | jq -r .name)
release_version=$(echo "$metadata" | jq -r .version)
name="pkg/$release_name-$release_version"
content_type="Content-Type: multipart/form-data"
auth_header="Authorization: Bearer $FORGE_API_KEY"
file_name="$name.tar.gz"

echo $file_name

#Prepare module for publishing
pdk build --force

#Publish module - missing flags: -fsS
curl -vX 'POST' \
 -F file="$file_name" \
 --header "$content_type" \
 --header "$auth_header" \
 "$url"

