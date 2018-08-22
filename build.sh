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

SOURCE_FILE=${NAME}-${VERSION}.tar.gz
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module add ci
module add gmp
module add mpfr
module add mpc
module add isl
module add ncurses
echo ${LD_LIBRARY_PATH}
echo ${PATH}

echo ${GMP_DIR} ${MPC_DIR} ${MPFR_DIR} ${ncurses_DIR}

echo "REPO_DIR is "
echo ${REPO_DIR}
echo "SRC_DIR is "
echo ${SRC_DIR}
echo "WORKSPACE is "
echo ${WORKSPACE}
echo "SOFT_DIR is"
echo ${SOFT_DIR}

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  mkdir -p ${SRC_DIR}
  wget http://mirror.ufs.ac.za/gnu/${NAME}/${NAME}-${VERSION}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
# GCC needs to be built outside of the src directory - see
# https://gcc.gnu.org/install/configure.html
mkdir ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

# LIBRARIES var is used by the makefile here, but also set by deploy modulefile
# We need to override it , or at least unset it temproarily
unset LANGUAGES
../configure \
--enable-gnu-unique-object \
CFLAGS=-fPIC \
--prefix=${SOFT_DIR} \
--with-ncurses=${NCURSES_DIR} \
--with-mpfr=${MPFR_DIR} \
--with-mpc=${MPC_DIR} \
--with-gmp=${GMP_DIR} \
--with-isl=${ISL_DIR} \
--enable-languages=c,c++,fortran,java,go \
--disable-multilib

make
