project(MiniXML)

cmake_minimum_required(VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/CMake")
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
endif()

# Determine the library version by extracting from the header file
file(STRINGS mxml.h MiniXML_VERSION_MAJOR
  REGEX "^[ \t]*#[ \t]*define[ \t]+MXML_MAJOR_VERSION[ \t]+[0-9]+.*")
string(REGEX REPLACE
  "^[ \t]*#[ \t]*define[ \t]+MXML_MAJOR_VERSION[ \t]+([0-9]+).*"
  "\\1" MiniXML_VERSION_MAJOR "${MiniXML_VERSION_MAJOR}")
file(STRINGS mxml.h MiniXML_VERSION_MINOR
  REGEX "^[ \t]*#[ \t]*define[ \t]+MXML_MINOR_VERSION[ \t]+[0-9]+.*")
string(REGEX REPLACE
  "^[ \t]*#[ \t]*define[ \t]+MXML_MINOR_VERSION[ \t]+([0-9]+).*"
  "\\1" MiniXML_VERSION_MINOR "${MiniXML_VERSION_MINOR}")

# Default to v2.7 if not found in the header file
if(NOT MiniXML_VERSION_MAJOR AND NOT MiniXML_VERSION_MINOR)
  message(WARNING "Unknown version.  Assuming 2.7")
  set(MiniXML_VERSION_MAJOR 2)
  set(MiniXML_VERSION_MINOR 7)
endif()
set(MiniXML_VERSION ${MiniXML_VERSION_MAJOR}.${MiniXML_VERSION_MINOR})
message(STATUS "Configuring MiniXML-${MiniXML_VERSION}")

option(WITH_VERSIONED_PREFIX "Use PREFIX/MiniXML-${MiniXML_VERSION}/ as an install prefix" OFF)
if(WITH_VERSIONED_PREFIX)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/MiniXML-${MiniXML_VERSION}/"
    CACHE PATH "Install path prefix, prepended onto install directories."
    FORCE)
endif()

include(SystemChecks)
configure_file(config.cmake.h.in ${PROJECT_BINARY_DIR}/config.h)

include_directories(${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR})

##########
# Library targets
##########

set(mxml_PUBLIC_SOURCES
  mxml.h
  mxml-attr.c mxml-entity.c mxml-file.c mxml-get.c
  mxml-index.c mxml-node.c mxml-search.c mxml-set.c
)
add_library(mxml
  ${mxml_PUBLIC_SOURCES}
  mxml-private.h mxml-private.c mxml-string.c
)
set_target_properties(mxml PROPERTIES
  VERSION ${MiniXML_VERSION}
  SOVERSION ${MiniXML_VERSION}
)
set_property(TARGET mxml APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)
if(HAVE_PTHREAD_H)
  set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
  find_package(Threads)
  target_link_libraries(mxml ${CMAKE_THREAD_LIBS_INIT})
endif()
install(TARGETS mxml EXPORT MiniXMLTargets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)
install(FILES mxml.h DESTINATION include COMPONENT Devel)

##########
# Documentation
##########

option(BUILD_DOCUMENTATION "Enable documentation generation" FALSE)
if(BUILD_DOCUMENTATION)
  add_executable(mxmldoc mxmldoc.c)
  target_link_libraries(mxmldoc mxml)
  add_subdirectory(doc)
endif()

##########
# Tests
##########

option(BUILD_TESTING "Enable test suite" FALSE)
if(BUILD_TESTING)
  enable_testing()
  add_executable(testmxml testmxml.c)
  target_link_libraries(testmxml mxml)
  add_subdirectory(test)
endif()

##########
# Package export logic to generate the MiniXMLConfig.cmake
##########

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/MiniXMLConfigVersion.cmake"
  VERSION ${MiniXML_VERSION}
  COMPATIBILITY AnyNewerVersion
)
export(EXPORT MiniXMLTargets
  FILE ${PROJECT_BINARY_DIR}/MiniXMLTargets.cmake
  NAMESPACE MiniXML::
)
configure_file(CMake/MiniXMLConfig.cmake
  "${PROJECT_BINARY_DIR}/MiniXMLConfig.cmake"
  COPYONLY
)

install(EXPORT MiniXMLTargets
  FILE MiniXMLTargets.cmake
  NAMESPACE MiniXML::
  DESTINATION cmake
  COMPONENT Devel
)
install(
  FILES
    "${PROJECT_BINARY_DIR}/MiniXMLConfig.cmake"
    "${PROJECT_BINARY_DIR}/MiniXMLConfigVersion.cmake"
  DESTINATION cmake
  COMPONENT Devel
)
