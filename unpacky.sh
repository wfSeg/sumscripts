#!/bin/bash

# unpacker

mkdir /usr/local/sbin/smctools/
tar -xf /usr/local/sbin/smctools/packy.tar -C /usr/local/sbin/smctools/ --strip 1
chmod +x /usr/local/sbin/smctools/SMCIPMITool
chmod +x /usr/local/sbin/smctools/sum