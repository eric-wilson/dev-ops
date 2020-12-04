# most of the scripts in this directoy can be added as user-data
# but there are times, that you may want to execute them afterwards
# especially when testing. this will help you do that.


# example: ec2-user@ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com
ec2_instance="PASTE_IN_YOUR_EC2_ADDRESS"
# paste in your ssh key path or add it to an enviornment variable
ssh_key=${AWS_SSH_KEY_PATH} 
# temp directory, where our scripts will go
path="/tmp"


upload_script_and_install() {

  script=$1

  if test -f "${script}"; then
    # make sure we have a place to put it
    ssh -i "${ssh_key}" ${ec2_instance} "sudo mkdir -p ${path}"

    # cp script to the server
    scp -i "${ssh_key}" ./${script} "${ec2_instance}:/${path}/${script}"

    # give it permssions
    ssh -i "${ssh_key}" ${ec2_instance} "sudo chmod +x /${path}/${script}"

    # execute the script(s)
    ssh -i "${ssh_key}" ${ec2_instance} "sudo /${path}/${script}"
  else
    echo "[Error]: File not found: ${script}"
  fi 
}


# execute the scripts
# example
#upload_script_and_install "ec2-install-ebs.sh"
#upload_script_and_install "ec2-install-httpd.sh"