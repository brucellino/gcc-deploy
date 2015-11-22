#!/bin/bash -e
. /etc/profile.d/modules.#!/bin/sh

SOURCE_FILE=${NAME}-${VERSION}.tar.gz
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module avail
module add ci
module list
module avail
module load gmp/5.1.3
module load mpfr/3.1.2
module load mpc/1.0.1

echo ${LD_LIBRARY_PATH}
echo ${PATH}

echo ${MPC_DIR} ${MPFR_DIR} ${ncurses_DIR}

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

if [[ -s ${SRC_DIR}/${SOURCE_FILE} ]] ; then
  echo "seems like this is the first build - let's get the source"
  mkdir -p ${SRC_DIR}
  wget http://mirror.ufs.ac.za/gnu/gnu/${NAME}/${NAME}-${VERSION}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
  tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
fi
cd ${WORKSPACE}/${NAME}-${VERSION}

./configure --prefix=${SOFT_DIR} \
--with-ncurses=${ncurses_DIR} \
--with-mpfr=${MPFR_DIR} \
--with-mpc=$MPC_DIR \
--enable-languages=c,c++,fortran,java \
--disable-multilib

make
