#!/bin/bash

svn up --username ldapguest --password 123ewq123ewq123ewq --non-interactive /data/svnClient/salt-cntv
python checkSaltKey.py
