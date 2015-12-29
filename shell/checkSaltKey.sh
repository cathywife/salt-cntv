#!/bin/bash

svn up --username ldapguest --password 123ewq123ewq123ewq --non-interactive /data/svnClient/devStaff
python checkSaltKey.py
