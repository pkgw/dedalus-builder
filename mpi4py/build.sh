#! /bin/bash

export LDFLAGS="-Wl,-rpath,/a/lib"

exec python setup.py install --single-version-externally-managed --record=files.txt
