#!/bin/bash
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

set -e
eval $($DEDALUS_BUILDER_SETUP)

# TODO: we should maybe just have the user create ~/.numpy-site.cfg rather
# than trying to code up all possible settings they might want.

cat >site.cfg <<EOF
[ALL]
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include
EOF

# Sigh, what a hack

if [ "$CC" = icc ] ; then
    build_flags=(--compiler=intelem --fcompiler=intelem)
else
    build_flags=()
fi

$PYTHON setup.py config "${build_flags[@]}"
$PYTHON setup.py build "${build_flags[@]}"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
