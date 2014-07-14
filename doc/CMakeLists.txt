find_program(HTMLDOC_BINARY htmldoc)
if(NOT HTMLDOC_BINARY)
  message(FATAL_ERROR "htmldoc executable is required to build documentation")
endif()

add_custom_command(OUTPUT mxml.pdf
  COMMAND ${HTMLDOC_BINARY} --verbose 
    --path \"${CMAKE_CURRENT_SOURCE_DIR}/hires\;${CMAKE_CURRENT_SOURCE_DIR}\"
    --batch ${CMAKE_CURRENT_SOURCE_DIR}/mxml.book -f mxml.pdf
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/mxml.pdf DESTINATION share/doc/mxml)

add_custom_command(OUTPUT mxml.html
  COMMAND ${HTMLDOC_BINARY} --verbose 
    --path \"${CMAKE_CURRENT_SOURCE_DIR}/hires\;${CMAKE_CURRENT_SOURCE_DIR}\"
    --batch ${CMAKE_CURRENT_SOURCE_DIR}/mxml.book --no-title -f mxml.html
)
install(
  FILES
    0.gif 1.gif 2.gif 3.gif 4.gif A.gif B.gif C.gif D.gif mxmldoc.xsd
    ${CMAKE_CURRENT_BINARY_DIR}/mxml.html
  DESTINATION share/doc/mxml
)

add_custom_command(OUTPUT mxml.d
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/mxml.d
  COMMAND ${HTMLDOC_BINARY} --verbose 
    --path \"${CMAKE_CURRENT_SOURCE_DIR}/hires\;${CMAKE_CURRENT_SOURCE_DIR}\"
    --batch ${CMAKE_CURRENT_SOURCE_DIR}/mxml.book --no-title -t html -d mxml.d
)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mxml.d DESTINATION share/doc/mxml)

install(FILES README COPYING CHANGES DESTINATION share/doc/mxml)

add_custom_target(documentation ALL DEPENDS mxml.pdf mxml.html mxml.d mxml.xml)

if(NOT CMAKE_CROSSCOMPILING)
  add_custom_command(OUTPUT mxml.xml reference.html
    COMMAND $<TARGET_FILE:mxmldoc>
      --header doc/reference.heading
      ${CMAKE_CURRENT_BINARY_DIR}/mxml.xml ${mxml_PUBLIC_SOURCES}
      > ${CMAKE_CURRENT_BINARY_DIR}/reference.html
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  )
  install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/mxml.xml 
      ${CMAKE_CURRENT_BINARY_DIR}/reference.html
    DESTINATION share/doc/mxml
  )
  add_custom_target(mxmldoc_genxml DEPENDS mxml.xml reference.html)
  add_dependencies(documentation mxmldoc_genxml)
endif()
