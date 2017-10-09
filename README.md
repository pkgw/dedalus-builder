# dedalus-builder

The scripts in this repository make it easy to install Dedalus on your system
in a way that leverages your system’s native MPI implementation.

## The approach

We use Anaconda Python and its `conda` tool to make packages of Dedalus and
its dependencies. For dependencies that do not depend sensitively on your
system’s particular characteristics, we use pre-built packages from the
[conda-forge](https://conda-forge.org/) project. But when we can take
advantage of your system MPI installation, we build custom packages.

You can then install these packages into new directory to create a
self-contained Python installation that includes Dedalus and its dependencies.
Or, if you already have an Anaconda installation, you can install the packages
into that directory.

The packages built by this tool include binary code that depends on your
computer's pre-existing MPI setup. So they *might* be portable to other
systems, if they have a compatible setup, but they probably won’t be.

## Instructions

First, set up your shell environment so that the programs can identify any
system libraries you wish to use:

- If you wish to use a system MPI installation, make sure that the desired
  `mpicc` program is in your `$PATH`. Otherwise, Anaconda’s prepackaged
  MPI implementation will be used.

Then, run `./initialize`. This will download and set up a self-contained
version of the Conda build infrastructure.

Then, run `./configure`. This will validate your build configuration and save
its parameters. If you want, you can alter your environment and rerun this
script.

Then run `./build-all`. This will compile Dedalus and its the MPI-sensitive
dependencies, creating binary package files in the Conda format. The goal is
that these builds should succeed reliably but there are likely bugs that
need to be shaken out.

Once the packages are built, you have two installation choices. By running
`./install-fresh <prefix>`, you can create a new, self-contained Python
installation that contains Dedalus and IPython. By running `./install-into
<prefix>`, you can install Dedalus into a preexisting Anaconda Python
installation.
