#! /bin/bash
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

set -e
eval $($DEDALUS_BUILDER_SETUP)

mkdir -p $PREFIX/lib
cp -a lib/* $PREFIX/lib
