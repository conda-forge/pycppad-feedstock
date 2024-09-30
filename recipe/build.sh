#!/bin/sh

mkdir build
cd build

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
  export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

  echo "Copying files from $BUILD_NUMPY_INCLUDE_DIRS to $TARGET_NUMPY_INCLUDE_DIRS"
  mkdir -p $TARGET_NUMPY_INCLUDE_DIRS
  cp -r $BUILD_NUMPY_INCLUDE_DIRS/numpy $TARGET_NUMPY_INCLUDE_DIRS
fi

# cppadcodegen package doesn't exists on linux_aarch64 and linux_ppc64le architecture
export BUILD_WITH_CPPAD_CODEGEN_BINDINGS=1
echo $HOST
if [[ $HOST =~ linux ]]; then
  if [[ $HOST =~ aarch64 || $HOST =~ powerpc64le ]]; then
    export BUILD_WITH_CPPAD_CODEGEN_BINDINGS=0
  fi
fi

echo BUILD_WITH_CPPAD_CODEGEN_BINDINGS $BUILD_WITH_CPPAD_CODEGEN_BINDINGS

cmake ${CMAKE_ARGS} .. \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DCMAKE_CROSSCOMPILING=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CROSSCOMPILING_EMULATOR=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CXX_STANDARD=11 \
      -DBUILD_WITH_CPPAD_CODEGEN_BINDINGS=$BUILD_WITH_CPPAD_CODEGEN_BINDINGS \
      -DPython3_NumPy_INCLUDE_DIR=$TARGET_NUMPY_INCLUDE_DIRS \
      -DPYTHON_EXECUTABLE=$PYTHON

ninja
ninja install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/pycppad/pycppadTargets.cmake
  rm $PREFIX/lib/cmake/pycppad/pycppadTargets.cmake.back
fi
