[![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=gcc-deploy)](https://ci.sagrid.ac.za/job/gcc-deploy) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.572588.svg)](https://doi.org/10.5281/zenodo.572588)


# GCC-deploy

This is the repo for build, test and deploy scripts for the [GNU Compiler Collection (GCC)](https://gcc.gnu.org/) for CODE-RADE

# Versions

We build the latest stable version of each major release of the compiler chain :

## Current versions :

  1. 4.9.4
  1. 5.4.0
  2. 6.3.0

## Old versions

There are also a few old modules from previous releases. YMMV.

1. ~~4.9.2~~
1. ~~5.1.0~~
1. ~~5.2.0~~
1. ~~5.3.0~~
1. ~~6.1.0~~

Version 7.x is not built yet, due to support for java being removed.


# Downstream products

Almost all CODE-RADE applications in research domains (astronomy, biology, chemistry, _etc_) are built with one or more of these compilers. As such, the modulefiles usually set a `GCC_VERSION` variable which is used to resolve the relevant version of the application. This is set in the `gcc` modulefile, such that `module add gcc/6.4.0` would set `GCC_VERSION=6.4.0`

# Using

Choose a compiler version, and do

```
    module add gcc/<version>
```

_e.g._ :

```
    module add gcc/6.3.0
```

# Citing

If you use this compiler in your toolchain, please cite :

Bruce Becker, & Sakhile Masoka. (2017). SouthAfricaDigitalScience/gcc-deploy: CODE-RADE Foundation Release 3 - GCC [Data set]. Zenodo. http://doi.org/10.5281/zenodo.572588
