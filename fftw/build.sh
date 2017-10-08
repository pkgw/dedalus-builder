#! /bin/bash

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
rm -f $lib/*.la
rm -rf share/info share/man
