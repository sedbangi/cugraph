# =============================================================================
# Copyright (c) 2022-2024, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
# =============================================================================

cmake_minimum_required(VERSION 3.26.4 FATAL_ERROR)

include(../../rapids_config.cmake)

# We always need CUDA for cuML because the raft dependency brings in a
# header-only cuco dependency that enables CUDA unconditionally.
include(rapids-cuda)
rapids_cuda_init_architectures(pylibcugraph-python)

project(
  pylibcugraph-python
  VERSION "${RAPIDS_VERSION}"
  LANGUAGES CXX CUDA
)

################################################################################
# - User Options  --------------------------------------------------------------
option(FIND_CUGRAPH_CPP "Search for existing CUGRAPH C++ installations before defaulting to local files"
       OFF
)
option(USE_CUDA_MATH_WHEELS "Use the CUDA math wheels instead of the system libraries" OFF)

# If the user requested it we attempt to find CUGRAPH.
if(FIND_CUGRAPH_CPP)
  find_package(cugraph "${RAPIDS_VERSION}" REQUIRED)
else()
  set(cugraph_FOUND OFF)
endif()

include(rapids-cython-core)

if (NOT cugraph_FOUND)
  find_package(CUDAToolkit REQUIRED)

  set(BUILD_TESTS OFF)
  set(BUILD_CUGRAPH_MG_TESTS OFF)
  set(CUDA_STATIC_RUNTIME ON)
  set(CUDA_STATIC_MATH_LIBRARIES ON)
  set(USE_RAFT_STATIC ON)
  set(CUGRAPH_COMPILE_RAFT_LIB ON)

  if(CUDAToolkit_VERSION VERSION_GREATER_EQUAL 12.0)
    set(CUDA_STATIC_MATH_LIBRARIES OFF)
  elseif(USE_CUDA_MATH_WHEELS)
    message(FATAL_ERROR "Cannot use CUDA math wheels with CUDA < 12.0")
  endif()

  add_subdirectory(../../cpp cugraph-cpp EXCLUDE_FROM_ALL)

  if(NOT CUDA_STATIC_MATH_LIBRARIES AND USE_CUDA_MATH_WHEELS)
    set(rpaths
      "$ORIGIN/../nvidia/cublas/lib"
      "$ORIGIN/../nvidia/curand/lib"
      "$ORIGIN/../nvidia/cusolver/lib"
      "$ORIGIN/../nvidia/cusparse/lib"
      "$ORIGIN/../nvidia/nvjitlink/lib"
    )
    set_property(TARGET cugraph PROPERTY INSTALL_RPATH ${rpaths} APPEND)
  endif()

  set(cython_lib_dir pylibcugraph)
  install(TARGETS cugraph DESTINATION ${cython_lib_dir})
  install(TARGETS cugraph_c DESTINATION ${cython_lib_dir})
endif()

rapids_cython_init()

add_subdirectory(pylibcugraph)

if(DEFINED cython_lib_dir)
  rapids_cython_add_rpath_entries(TARGET cugraph PATHS "${cython_lib_dir}")
endif()
