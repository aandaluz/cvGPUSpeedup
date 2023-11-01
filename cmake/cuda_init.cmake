cmake_policy(SET CMP0104 NEW) # Initialize CMAKE_CUDA_ARCHITECTURES when CMAKE_CUDA_COMPILER_ID is NVIDIA

 

if(UNIX)
    return()
endif()

set(CUDA_PATH $ENV{CUDA_PATH})

# parse component versions

function(get_cuda_component_version COMPONENT COMPONENT_VERSION)
    file(READ ${CUDA_PATH}/version.json CUDA_VERSION_FILE_JSON_STRING)
    string(JSON COMPONENT_JSON_STRING GET ${CUDA_VERSION_FILE_JSON_STRING} ${IDX} ${COMPONENT})
    string(JSON COMPONENT_JSON_STRING_1 GET ${COMPONENT_JSON_STRING} ${IDX} version)
    set(${COMPONENT_VERSION} ${COMPONENT_JSON_STRING_1} PARENT_SCOPE)
endfunction()

# Get the name from the current JSON element.
get_cuda_component_version("cuda" CUDA_VERSION_FROM_VERSION_FILE)
# findcudatookit requires nvcc version instead of cuda sdk version
get_cuda_component_version("cuda_nvcc" CUDA_NVCC_VERSION_FROM_VERSION_FILE)
message(STATUS "Found cuda version " ${CUDA_VERSION_FROM_VERSION_FILE})


# for ninja in CI we will always use the NVCC path
if(CMAKE_GENERATOR MATCHES "Ninja")
    set(CMAKE_CUDA_COMPILER ${CUDA_PATH}/nvcc/bin/nvcc.exe)
    set(CUDAToolkit_ROOT ${CUDA_PATH}/nvcc)
endif()
if(CMAKE_GENERATOR MATCHES "Visual Studio")
    set(CUDAToolkit_ROOT ${CUDA_PATH}/nvcc)
endif()

if(CMAKE_GENERATOR MATCHES "Visual Studio")
    # asume visual studio 2017 or newer other visual studio versions (2019) might be supported in the future
    set(ARCH "x64")
    set(CMAKE_GENERATOR_PLATFORM ${ARCH})
    set(CMAKE_GENERATOR_TOOLSET "host=${ARCH}")
endif()
