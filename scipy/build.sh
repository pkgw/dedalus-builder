#!/bin/bash
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

set -e
eval $($DEDALUS_BUILDER_SETUP)

export LIBRARY_PATH="${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

if [[ $(uname) == Darwin ]]; then
    # Also, included a workaround so that `-stdlib=c++` doesn't go to
    # `gfortran` and cause problems.
    #
    # https://github.com/conda-forge/toolchain-feedstock/pull/8
    export CFLAGS="-stdlib=libc++ -lc++ $CFLAGS"
    export LDFLAGS="-headerpad_max_install_names -undefined dynamic_lookup -bundle -Wl,-search_paths_first -lc++"
else
    unset LDFLAGS
fi

exec $PYTHON setup.py install --single-version-externally-managed --record=record.txt
