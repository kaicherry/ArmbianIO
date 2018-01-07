#!/bin/sh

# Create Python bindings as armbianio module

# Run in the python dir of the ArmbianIO project

# Clean up
rm -f armbianio_wrap.c *.o *.so armbianio/armbianio.*
sudo rm -f /usr/local/lib/_armbianio.so

# Install python-dev
if [ $(dpkg-query -W -f='${Status}' python-dev 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get -y install python-dev
fi

# Install pip
if ! command -v pip
then
	sudo apt-get -y install python-pip
	sudo -H pip install --upgrade pip setuptools
	sudo apt-get -y purge python-pip
	sudo apt -y autoremove
fi

# Install swig
if [ $(dpkg-query -W -f='${Status}' swig 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get -y install swig
fi

# Get python includes
includes=$(python-config --includes)

# Generate module in package
swig -python -outdir armbianio armbianio.i

# Compile wrapper
gcc -c -Wall -O2 -fPIC ../armbianio.c armbianio_wrap.c $includes

# Link objects
ld -shared armbianio.o armbianio_wrap.o -o _armbianio.so

# Deploy shared library
sudo cp _armbianio.so /usr/local/lib/.

# Install Python package
sudo -H pip install -e .