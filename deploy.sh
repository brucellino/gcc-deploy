#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
echo ${SOFT_DIR}
# Now, dependencies
module add gmp
module add mpfr
module add mpc
module add isl
module add ncurses

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
echo "Cleaning previous build"
make distclean

# LIBRARIES var is used by the makefile here, but also set by deploy modulefile
# We need to override it , or at least unset it temproarily
unset LANGUAGES
../configure --prefix=${SOFT_DIR} \
--with-ncurses=${NCURSES_DIR} \
--with-mpfr=${MPFR_DIR} \
--with-mpc=${MPC_DIR} \
--with-gmp=${GMP_DIR} \
--with-isl=${ISL_DIR} \
--enable-gnu-unique-object \
--enable-languages=c,c++,fortran,java,go \
--disable-multilib
make
make install
mkdir -p ${COMPILERS}/${NAME}
module refresh
# Now, create the module file for deployment
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/mpc-deploy"
module add ncurses
module add gmp
module add mpfr
module add mpc

setenv GCC_VERSION $VERSION
setenv GCC_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv CFLAGS "${CFLAGS} -I$::env(GCC_DIR)/include -L$::env(GCC_DIR)/lib -L$::env(GCC_DIR)/lib64"
prepend-path PATH $::env(GCC_DIR)/bin
prepend-path MANPATH $::env(GCC_DIR)/man
prepend-path LD_LIBRARY_PATH $::env(GCC_DIR)/lib
prepend-path LD_LIBRARY_PATH $::env(GCC_DIR)/lib64
setenv CC $::env(GCC_DIR)/bin/gcc
setenv GCC $::env(GCC_DIR)/bin/gfortran
setenv F77 $::env(GCC_DIR)/bin/gfortran
setenv F90 $::env(GCC_DIR)/bin/gfortran
MODULE_FILE
) > ${COMPILERS}/${NAME}/${VERSION}

echo "Checking modules"
cd ${WORKSPACE}
echo "Testing the module availability"
module avail ${NAME}/${VERSION}

echo "Testing the module"

module add ${NAME}/${VERSION}

echo "Checking gcc"
which gcc

echo "Checking fortran compile"

gfortran -o hello-fortran hello-world.f90
echo "running fortran hello world "
./hello-fortran
echo "Checking g++ compile"
g++ -o hello-c++ hello-world.c
echo "Running C++ hello world"
./hello-c++
