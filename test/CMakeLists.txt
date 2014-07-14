add_test(NAME GenerateOutput1
  COMMAND ${CMAKE_COMMAND}
    -DEXEC_COMMAND=$<TARGET_FILE:testmxml>
    -DEXEC_ARGS=${PROJECT_SOURCE_DIR}/test.xml
    -DEXEC_OUTPUT_FILE=temp1.xml
    -DEXEC_ERROR_FILE=temp1s.xml
    -P ${PROJECT_SOURCE_DIR}/CMake/execute_capture.cmake
)

add_test(NAME String
  COMMAND ${CMAKE_COMMAND} -E compare_files temp1.xml temp1s.xml
)
set_tests_properties(String PROPERTIES DENENDS test-GenerateOutput1)

add_test(NAME GenerateOutput2
  COMMAND ${CMAKE_COMMAND}
    -DEXEC_COMMAND=$<TARGET_FILE:testmxml>
    -DEXEC_ARGS=temp1.xml
    -DEXEC_OUTPUT_FILE=temp2.xml
    -DEXEC_ERROR_FILE=temp2s.xml
    -P ${PROJECT_SOURCE_DIR}/CMake/execute_capture.cmake
)

add_test(NAME Stdio
  COMMAND ${CMAKE_COMMAND} -E compare_files temp1.xml temp2.xml
)
set_tests_properties(String PROPERTIES DENENDS test-GenerateOutput2)

add_test(NAME FileDescriptor
  COMMAND ${CMAKE_COMMAND} -E compare_files
    ${PROJECT_SOURCE_DIR}/test.xml ${PROJECT_SOURCE_DIR}/test.xmlfd
)
set_tests_properties(String PROPERTIES DENENDS Stdio)
