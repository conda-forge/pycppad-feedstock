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

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DCMAKE_CROSSCOMPILING=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CROSSCOMPILING_EMULATOR=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CXX_STANDARD=11 \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT}
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/pycppad/pycppadTargets.cmake
  rm $PREFIX/lib/cmake/pycppad/pycppadTargets.cmake.back
fi
