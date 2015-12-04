#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
# Now, dependencies
module add gmp
module add mpfr
module add ncurses
module add mpc
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
echo "Cleaning previous build"
make distclean
../configure --prefix=${SOFT_DIR} \
--with-ncurses=${ncurses_DIR} \
--with-mpfr=${MPFR_DIR} \
--with-mpc=${MPC_DIR} \
--with-gmp=${GMP_DIR} \
--enable-languages=c,c++,fortran,java \
--disable-multilib
make
make install
mkdir -p ${COMPILERS_MODULES}/${NAME}

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
prereq mpfr
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/mpc-deploy"
module add ncurses
module add gmp
module add mpfr
module add mpc

setenv GCC_VERSION $VERSION
set GCC_DIR $::env(CVMFS_DIR)$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH \$GCC_DIR/include
prepend-path PATH \$GCC_DIR/bin
prepend-path MANPATH \$GCC_DIR/man
prepend-path LD_LIBRARY_PATH \$GCC_DIR/lib
prepend-path LD_LIBRARY_PATH \$GCC_DIR/lib64
setenv CC \$GCC_DIR/bin/gcc
setenv GCC \$GCC_DIR/bin/gcc
setenv FC \$GCC_DIR/bin/gfortran
setenv F77 \$GCC_DIR/bin/gfortran
setenv F90 \$GCC_DIR/bin/gfortran
MODULE_FILE
) > ${COMPILERS_MODULES}/${NAME}/${VERSION}
