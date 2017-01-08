#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
#module load ncurses/5.1.3
module add gmp
module load mpfr
module load mpc
module add ncurses

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
# According to https://gcc.gnu.org/install/test.html
# should run tests in the objdir of the build.
echo "Running CI install to $SOFT_DIR"
make install
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
module add ncurses
module add gmp
module add mpfr
module add mpc
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
mkdir -p ${COMPILERS_MODULES}/${NAME}
cp modules/${VERSION} ${COMPILERS_MODULES}/${NAME}
