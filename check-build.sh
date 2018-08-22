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

. /etc/profile.d/modules.sh
module add ci
module add gmp
module add mpfr
module add mpc
module add isl/0.15
module add ncurses

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
# According to https://gcc.gnu.org/install/test.html
# should run tests in the objdir of the build.
echo "Running CI install to $SOFT_DIR"
unset LANGUAGES
make install
#  We need to get $LIBRARIES back again
module refresh
echo "Checking LANGUAGES var"
echo ${LANGUAGES}

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
  puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis "Sets the environment for using $NAME ($VERSION.)"
module add gmp
module add mpfr
module add mpc
module add isl
module add ncurses

setenv GCC_VERSION $VERSION
setenv GCC_DIR /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH $::env(GCC_DIR)/include
prepend-path PATH $::env(GCC_DIR)/bin
prepend-path MANPATH $::env(GCC_DIR)/man
prepend-path LD_LIBRARY_PATH $::env(GCC_DIR)/lib
prepend-path LD_LIBRARY_PATH $::env(GCC_DIR)/lib64
setenv CC $::env(GCC_DIR)/bin/gcc
setenv GCC $::env(GCC_DIR)/bin/gcc
setenv FC $::env(GCC_DIR)/bin/gfortran
setenv F77 $::env(GCC_DIR)/bin/gfortran
setenv F90 $::env(GCC_DIR)/bin/gfortran
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${COMPILERS}/${NAME}
cp modules/${VERSION} ${COMPILERS}/${NAME}

echo "Testing the module availability"
module avail ${NAME}/${VERSION}
echo "Testing the module"

module add ${NAME}/${VERSION}

echo "Checking gcc"
which gcc
cd ${WORKSPACE}
echo "Checking fortran compile"

gfortran -o hello-fortran hello-world.f90
echo "running fortran hello world "
./hello-fortran
echo "Checking g++ compile"
g++ -o hello-c++ hello-world.c
echo "Running C++ hello world"
./hello-c++
