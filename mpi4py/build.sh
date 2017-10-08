#! /bin/bash
#
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

export LDFLAGS="-Wl,-rpath,/a/lib"

exec python setup.py install --single-version-externally-managed --record=files.txt
