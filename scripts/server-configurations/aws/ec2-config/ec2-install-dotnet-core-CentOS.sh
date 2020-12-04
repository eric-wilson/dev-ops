#!/bin/bash -ex


################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

################################################################################################################################
# package manager update
sudo yum update -y
# / package manager update
################################################################################################################################



#Install the ASP.NET Core 5.0 runtime: aspnetcore-runtime-5.0
#Install the .NET Core 2.1 runtime: dotnet-runtime-2.1
#Install the .NET 5.0 SDK: dotnet-sdk-5.0
#Install the .NET Core 3.1 SDK: dotnet-sdk-3.1

version="aspnetcore-runtime-5.0"

################################################################################################################################
# install .net core CentOS
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sudo yum install ${version} -y

# install .net core
################################################################################################################################



################################################################################################################################
# .net core
# verify
echo "dotnet vesions: $(dotnet --version)"
# / .net core
################################################################################################################################
