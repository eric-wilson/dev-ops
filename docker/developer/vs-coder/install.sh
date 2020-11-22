

sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update 
  

# allows for adding custom repository locations (apt-add-repository)
sudo apt install -y software-properties-common 
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# make sure to get the correct ubuntu based on the version you are on
VER=$(lsb_release -sr)
sudo apt-add-repository "https://packages.microsoft.com/ubuntu/${VER}/prod"

# update / refresh
sudo apt-get update

# install .net5
sudo apt-get install -y dotnet-sdk-5.0

# install git (if needed)
apt-get install -y git