#!/bin/bash
set -ex

mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CPP_LIB=ON \
    -DBUILD_PYTHON_LIB=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DPython_EXECUTABLE=$PYTHON \
    -DCMAKE_CXX_COMPILER_RANLIB=$RANLIB \
    -DCMAKE_C_COMPILER_RANLIB=$RANLIB \
    -DSDL_SUPPORT=ON \
    ..

cmake --build .
cmake --install . --prefix $PREFIX

cd ..

# see https://github.com/mgbellemare/Arcade-Learning-Environment/blob/v0.7.5/setup.py#L109-L150
export CIBUILDWHEEL=1
export GITHUB_REF=$PKG_VERSION

$PYTHON -m pip install . -vv
