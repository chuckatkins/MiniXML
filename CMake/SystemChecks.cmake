# Test for the C inline keyword
if(NOT MXML_INLINE)
  message(STATUS "Checking for inline")
  foreach(TEST_INLINE inline __inline__ __inline "")
    try_compile(TEST_INLINE_BIN "${PROJECT_BINARY_DIR}"
      "${PROJECT_SOURCE_DIR}/CMake/test_inline.c"
      COMPILE_DEFINITIONS "-DINLINE=${TEST_INLINE}"
    )
    if(TEST_INLINE_BIN)
      set(MXML_INLINE ${TEST_INLINE})
      break()
    endif()
  endforeach()
  message(STATUS "Checking for inline - ${MXML_INLINE}")
endif()

include(CheckTypeSize)
CHECK_TYPE_SIZE("long long" LONG_LONG)

include(CheckFunctionExists)
set(CMAKE_EXTRA_INCLUDE_FILES stdio.h)
CHECK_FUNCTION_EXISTS(snprintf HAVE_SNPRINTF)
CHECK_FUNCTION_EXISTS(vsnprintf HAVE_VSNPRINTF)

set(CMAKE_EXTRA_INCLUDE_FILES string.h)
CHECK_FUNCTION_EXISTS(strdup HAVE_STRDUP)
unset(CMAKE_EXTRA_INCLUDE_FILES)

include(CheckIncludeFiles)
CHECK_INCLUDE_FILES(pthread.h HAVE_PTHREAD_H)
