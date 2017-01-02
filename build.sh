#!/bin/bash -e
. /etc/profile.d/modules.sh

SOURCE_FILE=${NAME}-${VERSION}.tar.gz
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module avail
module add ci
module list
module avail
module add gmp/5.1.3
module add mpfr/3.1.2
module add mpc/1.0.1
module add ncurses
echo ${LD_LIBRARY_PATH}
echo ${PATH}

echo ${MPC_DIR} ${MPC_DIR} ${MPFR_DIR} ${ncurses_DIR}

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
  wget http://mirror.ufs.ac.za/gnu/gnu/${NAME}/${NAME}-${VERSION}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
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
../configure \
CFLAGS=-fPIC \
--prefix=${SOFT_DIR} \
--with-ncurses=${NCURSES_DIR} \
--with-mpfr=${MPFR_DIR} \
--with-mpc=${MPC_DIR} \
--with-gmp=${GMP_DIR} \
--enable-languages=c,c++,fortran,java \
--disable-multilib

make -j2
