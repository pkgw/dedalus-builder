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

# We could just copy files into our prefix, but it seems better to use symlinks.
# conda-build silently replaces out-of-tree symlinks with their content, though.
# We achieve the desired effect with a manually-constructed post-link script.

mkdir -p $PREFIX/bin $PREFIX/lib

post_link=$PREFIX/bin/.system-libs-post-link.sh
cat <<EOF >$post_link
#!/bin/bash
set -e
EOF
chmod +x $post_link

function depend_lib () {
    sys_lib_path="$1"
    lib_base=$(basename "$sys_lib_path")

    # Semi-canonicalize name (we use `pwd`, not `pwd -P`)
    d=$(cd $(dirname "$sys_lib_path") && pwd)
    sys_lib_path=$d/$lib_base

    # We don't have any dependencies at all, so if the destination file
    # already exists, someone already logged a dep on this library.

    if [ ! -f $PREFIX/lib/$lib_base ] ; then
        echo dummy >$PREFIX/lib/$lib_base
        echo "rm -f \$PREFIX/lib/$lib_base" >>$post_link
        echo "ln -s $sys_lib_path \$PREFIX/lib/$lib_base" >>$post_link
    fi
}


# MPI? If we're using system MPI, we identify needed libraries by compiling
# some test binaries that will link with needed MPI support libraries.

if [ $use_system_mpi -ne 0 ] ; then
    echo 'int main(int argc, char** argv) { return 0; }' >demo.c
    mpicc -o c_demo demo.c
    mpicxx -o cxx_demo demo.c

    cat <<'EOF' >demo.f90
       program hello
       end program hello
EOF
    mpif90 -o f90_demo demo.f90

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
                        depend_lib "$path" ;;
                esac
            done
        done

        # The shared library deps pull in the specific major versions (e.g. libmpi.so.1)
        # but for development we need the extension-free names too (e.g. libmpi.so). So,
        # patch up. This is why MPI comes first.

        cd $PREFIX/lib

        for lib in lib*.so.* ; do
            devname=$(echo $lib |sed -e 's/\.so\..*/.so/')e
            [ -e "$devname" ] || ln -s $lib $devname
        done

        cd -
    elif [ $(uname) = Darwin ] ; then
        echo >&2 "TODO: implement MPI probing for OSX"
        exit 1
    fi
fi


# Intel compiler? This is a bit of a hack.

if [ "$CC" = icc ] ; then
    for lib in $INTEL_LIB/lib*.so* ; do
        depend_lib "$lib"
    done
fi


# BLAS? As far as I can guess we just have to manually probe the prefix and
# symlink things that look like libraries of interest.

if [ $use_system_blas -ne 0 ] ; then
    for lib in $system_blas_dir/lib* ; do
        case "$lib" in
            *atlas*|*blas*|*lapack*|*mkl*)
                depend_lib "$lib" ;;
        esac
    done
fi
