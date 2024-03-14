#!/bin/bash

# Download POCO
URL="https://pocoproject.org/releases/poco-1.9.4/"
wget ${URL}poco-1.9.4-all.tar.gz

# Extract the archive to HOME folder
tar -xzvf poco-1.9.4-all.tar.gz -C ~/

# Delete the tar.gz file
rm poco-1.9.4-all.tar.gz

# Compile and install POCO
cd ~/poco-1.9.4-all/build
cmake ..
sudo make
sudo make install
cd ..
sudo ldconfig
