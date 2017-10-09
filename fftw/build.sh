#! /bin/bash
#
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

if [[ `uname` == 'Darwin' ]]; then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export CXXFLAGS="-stdlib=libc++"
    export CXX_LDFLAGS="-stdlib=libc++"
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"

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
