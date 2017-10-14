#! /bin/bash
#
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

set -e
eval $($DEDALUS_BUILDER_SETUP)

# see fftw-3.3.6/m4/ax_cc_maxopt.m4 for their default optimization flags,
# which only get applied if $CFLAGS is empty. Our build environment might set
# $CFLAGS so it is safest to ensure that the optimizer flags are always set.

if [[ `uname` == 'Darwin' ]]; then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export CFLAGS="$CFLAGS -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    export CXX_LDFLAGS="-stdlib=libc++ $CXX_LDFLAGS"
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
    export CFLAGS="$CFLAGS -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math"
fi

export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
export CFLAGS="$CFLAGS -I${PREFIX}/include"

configure_args=(
    --prefix=$PREFIX
    --with-pic
    --enable-shared
    --disable-static
    --enable-threads
    --enable-mpi
    CC=mpicc
    CXX=mpicxx
    F77=mpif90
    MPICC=mpicc
    MPICXX=mpicxx
)

build_cases=(
    "--enable-float --enable-sse --enable-sse2 --enable-avx"
    "--enable-sse2 --enable-avx"
    "--enable-long-double"
)

for extra_args in "${build_cases[@]}" ; do
    ./configure "${configure_args[@]}" $extra_args
    make -j${CPU_COUNT}
    make install
    #(cd tests && eval ${LIBRARY_SEARCH_VAR}=\"$PREFIX/lib\" make check-local) || exit $?
done

# Clean up the install a bit

cd $PREFIX
rm -f lib/*.la lib/*.a
rm -rf share/info share/man
