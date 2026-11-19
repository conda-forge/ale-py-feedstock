#!/bin/bash
set -ex

# C++ library and headers only; the python module is built by pip below
# (building it here as well installs a stray copy into $PREFIX/ale_py)
mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CPP_LIB=ON \
    -DBUILD_PYTHON_LIB=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DSDL_SUPPORT=ON \
    ..

cmake --build .
cmake --install . --prefix $PREFIX

cd ..

# see https://github.com/mgbellemare/Arcade-Learning-Environment/blob/v0.7.5/setup.py#L109-L150
export CIBUILDWHEEL=1
export GITHUB_REF=$PKG_VERSION

# picked up by scikit-build-core; the default in pyproject.toml is patched out
export CMAKE_ARGS="${CMAKE_ARGS} -DBUILD_VECTOR_XLA_LIB=${BUILD_VECTOR_XLA_LIB}"
if [[ "${BUILD_VECTOR_XLA_LIB}" == "ON" ]]; then
    XLA_DIR="$(${BUILD_PREFIX}/bin/python -c "from jax import ffi; print(ffi.include_dir())")"
    test -f "${XLA_DIR}/xla/ffi/api/ffi.h"
    export CMAKE_ARGS="${CMAKE_ARGS} -DXLA_DIR=${XLA_DIR}"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
