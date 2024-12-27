#!/bin/bash

# Free some space on the root partition
# ref: https://askubuntu.com/a/1461683/1674768

sudo journalctl --rotate
sudo journalctl --vacuum-size=100M
sudo apt-get autoremove
sudo apt-get autoclean
