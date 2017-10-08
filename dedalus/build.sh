#! /bin/bash

set -e

export FFTW_PATH=$PREFIX
export MPI_PATH=$PREFIX

export CC=mpicc
export CXX=mpicxx
export FC=mpif90

python setup.py build_ext --inplace
python setup.py install
