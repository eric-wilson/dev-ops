# warning this will replace the keys with what you have here
# so you should get a copy of the public key generated from the
# pem key that AWS generates.  To do this simply start a new EC2
# instance. Navigate to the authorized_keys directory and copy the
# ssh key. Then add it to this section along with any other keys you
# want to have access to your server
sudo cat -s > ~/.ssh/authorized_keys << EOF
# add your public key(s) here
EOF


# option 2 append a key
sudo echo "ENTER_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys

# do you need to generate a key use
# 