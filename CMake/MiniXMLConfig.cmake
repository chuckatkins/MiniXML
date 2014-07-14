if(NOT TARGET MiniXML::mxml)
  include("${CMAKE_CURRENT_LIST_DIR}/MiniXMLTargets.cmake")
endif()
set(MiniXML_LIBRARIES MiniXML:mxml)
