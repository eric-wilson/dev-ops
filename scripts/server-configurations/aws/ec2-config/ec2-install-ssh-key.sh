


# warning this will replace the keys with what you have here
sudo cat -s > ~/.ssh/authorized_keys << EOF
# add your key(s) here
EOF

# or to just append it
sudo echo "ENTER_YOUR_KEY_HERE" >> ~/.ssh/authorized_keys
