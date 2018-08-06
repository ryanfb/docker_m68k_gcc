
# docker_m68k_gcc

Dockerized environment for building an M68k cross-compiler toolchain. 
[`ryanfb/m68k_gcc` on Docker Hub](https://hub.docker.com/r/ryanfb/m68k_gcc/). Adapted from [these scripts for building a 68000 cross compiler](http://www.aaldert.com/outrun/gcc-auto.html).

## Introduction
All of the standard utilities (gcc, gas, etc) are prefixed with **m68k-elf-** to differentiate them from their native counterparts. This means that your build scripts need to call m68k-elf-gcc, m68k-elf-gas, etc.

## Usage
To build your source, simply run the appropriate commands inside the container: 

    docker run --rm \
      -v ${PWD}:/source
      -w /source
      make

Alternatively, create a shell script to do all the things:

    #!/bin/bash
    PREFIX=m68k-elf-
    # pull the latest docker image
    docker pull ryanfb/m68k_gcc
    # start the build
    docker run --rm -v ${PWD}:/source -w /source ${PREFIX}/gcc -o mycoolapp mycoolapp.c


    
    

