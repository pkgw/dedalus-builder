#! /bin/bash
#
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

set -e

# Compile some test binaries that will link with needed MPI support libraries.

echo 'int main(int argc, char** argv) { return 0; }' >demo.c
mpicc -o c_demo demo.c
mpicxx -o cxx_demo demo.c

cat <<'EOF' >demo.f90
       program hello
       end program hello
EOF
mpif90 -o f90_demo demo.f90

# Platform-specific futzing to create a package with symlinks to those
# libraries.

mkdir -p $PREFIX/lib

if [ $(uname) = Linux ] ; then
    for prog in c_demo cxx_demo f90_demo ; do
        ldd $prog |grep '=>' |while read soname arrow path address ; do
            if [ -z "$address" ] ; then
                continue # some ldd's give this: "linux-vdso.so.1 =>  (0x00007ffc26ba8000)"
            fi

            case $path in
                /lib*) ;;
                /usr/lib*) ;;
                *)
                    ln -sf $path $PREFIX/lib/$soname
                    ;;
            esac
        done
    done

    cd $PREFIX/lib

    for lib in lib*.so.* ; do
        devname=$(echo $lib |sed -e 's/\.so\..*/.so/')
        ln -sf $lib $devname
    done
elif [ $(uname) = Darwin ] ; then
    echo >&2 "TODO: implement MPI probing for OSX"
    exit 1
fi
