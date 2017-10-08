#! /bin/bash

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
            case $path in
                /lib*) ;;
                /usr/lib*) ;;
                *)
                    ln -sf $(realpath $path) $PREFIX/lib/$soname
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
