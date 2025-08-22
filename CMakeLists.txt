cmake_minimum_required(VERSION 3.23)
MESSAGE("\nConfiguring hypercine...\n")

PROJECT(hypercine LANGUAGES CXX C)

IF(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    MESSAGE("\nWarning: This is a windows build, but BUILD_SHARED_LIBS is OFF. Setting BUILD_SHARED_LIBS on automatically.")
    SET(BUILD_SHARED_LIBS ON)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

MESSAGE(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
SET(DICE_OUTPUT_PREFIX ${CMAKE_CURRENT_BINARY_DIR})
MESSAGE(STATUS "If 'make install' is exectued, the libraries will also be copied to: ${CMAKE_INSTALL_PREFIX}/lib")

# if debug messages are turned on:
IF(HYPERCINE_DEBUG_MSG)
  MESSAGE(STATUS "Debugging messages are ON")
  ADD_DEFINITIONS(-DHYPERCINE_DEBUG_MSG=1)
ELSE()
  MESSAGE(STATUS "Debugging messages are OFF")
ENDIF()

add_library(hypercine)

# base data type:
if(HYPERCINE_USE_DOUBLE_STORAGE OR HYPERCINE_USE_FLOAT_STORAGE OR HYPERCINE_USE_INT_STORAGE)
else()
  message(FATAL_ERROR "Storage type must be set with either HYPERCINE_USE_DOUBLE_STORAGE, HYPERCINE_USE_FLOAT_STORAGE, or HYPERCINE_USE_INT_STORAGE")
endif()
if(HYPERCINE_USE_DOUBLE_STORAGE AND HYPERCINE_USE_FLOAT_STORAGE)
  message(FATAL_ERROR "Cannot specify both HYPERCINE_USE_DOUBLE_STORAGE and HYPERCINE_USE_FLOAT_STORAGE")
endif()
if(HYPERCINE_USE_DOUBLE_STORAGE AND HYPERCINE_USE_INT_STORAGE)
  message(FATAL_ERROR "Cannot specify both HYPERCINE_USE_DOUBLE_STORAGE and HYPERCINE_USE_INT_STORAGE")
endif()
if(HYPERCINE_USE_FLOAT_STORAGE AND HYPERCINE_USE_INT_STORAGE)
  message(FATAL_ERROR "Cannot specify both HYPERCINE_USE_FLOAT_STORAGE and HYPERCINE_USE_INT_STORAGE")
endif()
if(HYPERCINE_USE_DOUBLE_STORAGE)
  target_compile_definitions(hypercine PUBLIC USE_DOUBLE_STORAGE DICE_USE_DOUBLE)
  MESSAGE(STATUS "Storage type will be: DOUBLE")
endif()
if(HYPERCINE_USE_FLOAT_STORAGE)
  target_compile_definitions(hypercine PUBLIC USE_FLOAT_STORAGE DICE_USE_FLOAT)
  MESSAGE(STATUS "Storage type will be: FLOAT")
endif()
if(HYPERCINE_USE_INT_STORAGE)
  target_compile_definitions(hypercine PUBLIC USE_INT_STORAGE DICE_USE_INT)
  MESSAGE(STATUS "Storage type will be: INT (uint16_t or unsigned short)")
endif()

SET (HYPERCINE_SOURCES
  ./src/hypercine.cpp
)

SET (HYPERCINE_HEADERS
 ./src/hypercine.h
)

target_compile_definitions(hypercine PRIVATE HYPERCINE_LIB_EXPORTS_MODE)
target_sources(
    ${PROJECT_NAME}
    PRIVATE ${HYPERCINE_SOURCES}
)
target_sources(
  ${PROJECT_NAME}
  PUBLIC FILE_SET HEADERS
  BASE_DIRS ${CMAKE_CURRENT_LIST_DIR}/src
  FILES ${HYPERCINE_HEADERS}
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

install(
  TARGETS  ${PROJECT_NAME}
  EXPORT   ${PROJECT_NAME}Targets
  FILE_SET HEADERS
)
install(
  EXPORT ${PROJECT_NAME}Targets
  NAMESPACE hypercine::
  DESTINATION ${CONFIG_INSTALL_DIR}
)

configure_package_config_file(
  ${CMAKE_SOURCE_DIR}/config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION ${CONFIG_INSTALL_DIR}
)
install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  DESTINATION ${CONFIG_INSTALL_DIR}
)

IF(DEFINED OpenCV_DIR)
  message(STATUS "Looking for OpenCV in dir: ${OpenCV_DIR}")
  find_package( OpenCV NO_DEFAULT_PATH PATHS ${OpenCV_DIR} )
  IF(NOT OpenCV_FOUND)
    message(FATAL_ERROR "OpenCV not found. OpenCV is required for building tests and tools")
  ENDIF()
  IF(WIN32)
    FILE(GLOB OPENCV_DLLS ${OpenCV_DIR}/x64/vc12/bin/*.dll)
    FILE(COPY ${OPENCV_DLLS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
    FILE(GLOB OPENCV_DLLS ${OpenCV_DIR}/bin/Release/*.dll)
    FILE(COPY ${OPENCV_DLLS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
    FILE(GLOB OPENCV_DLLS ${OpenCV_DIR}/x64/vc15/bin/*.dll)
    FILE(COPY ${OPENCV_DLLS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)
  ENDIF()
  # only add tests and tools for OpenCV builds
  # also only add tests and tools if BUILD_TESTS is defined in the do cmake file
  IF(BUILD_TESTS)
    add_subdirectory(tests)
    add_subdirectory(tools)
    add_subdirectory(performance)
  ENDIF()
ENDIF()
