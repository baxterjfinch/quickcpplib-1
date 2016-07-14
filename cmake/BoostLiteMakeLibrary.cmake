# Adds two targets, one a static and the other a shared library for ${PROJECT_NAME}
# 
# Outputs:
#  *  ${PROJECT_NAME}_sl: Static library target
#  *  ${PROJECT_NAME}_dl: Dynamic library target
#  * ${PROJECT_NAME}_slm: Static C++ Module target (where supported)
#  * ${PROJECT_NAME}_dlm: Dynamic C++ Module target (where supported)

include(BoostLiteDeduceLibrarySources)
if(NOT DEFINED ${PROJECT_NAME}_SOURCES)
  message(FATAL_ERROR "FATAL: Cannot include BoostLiteMakeLibrary without a src directory. "
                      "Perhaps you meant BoostLiteMakeHeaderOnlyLibrary?")
endif()

if(WIN32)
  function(check_if_cmake_incomplete target md5 path)
    string(REPLACE "/" "\\" TEMPFILE "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}\\boostlite_cmake_tempfile_${target}.txt")
    #string(REPLACE "/" "\\" CMAKE "\"${CMAKE_COMMAND}\")
    set(CMAKE "cmake")
    string(REPLACE "/" "\\" CMAKECACHE "${CMAKE_CURRENT_BINARY_DIR}\\CMakeCache.txt")
    add_custom_command(TARGET ${target} PRE_BUILD
      COMMAND echo Checking if files have been added to ${target} since cmake last auto globbed the source tree ... & dir /b /a-d /s > \"${TEMPFILE}\" & for /f \"delims=\" %%a in ('${CMAKE} -E md5sum \"${TEMPFILE}\"') do @set MD5=%%a & for /f \"tokens=1\" %%G IN (\"%MD5%\") DO set MD5=%%G & if NOT \"%MD5%\" == \"${md5} \" (echo WARNING cmake needs to be rerun! %MD5% != ${md5} & copy /b \"${CMAKECACHE}\" +,,)
      WORKING_DIRECTORY "${path}"
    )
  endfunction()
else()
  function(check_if_cmake_incomplete target md5 path)
    add_custom_command(TARGET ${target} PRE_BUILD
      COMMAND echo Checking if files have been added to ${target} since cmake last auto globbed the source tree ... ; find . -type f -printf \"%t\\t%s\\t%p\\n\" > \"${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/boostlite_cmake_tempfile_${target}.txt\" ; MD5=$(\"${CMAKE_COMMAND}\" -E md5sum \"${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/boostlite_cmake_tempfile_${target}.txt\" | cut -d " " -f1) ; if [ \"$MD5\" != \"${md5}\" ] ; then echo WARNING cmake needs to be rerun! $MD5 != ${md5} ; touch \"${CMAKE_CURRENT_BINARY_DIR}/CMakeCache.txt\" ; fi
      WORKING_DIRECTORY "${path}"
    )
  endfunction()
endif()

# Only explicitly exported symbols are to be available from shared objects
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

add_library(${PROJECT_NAME}_sl STATIC ${${PROJECT_NAME}_HEADERS} ${${PROJECT_NAME}_SOURCES})
list(APPEND ${PROJECT_NAME}_TARGETS ${PROJECT_NAME}_sl)
check_if_cmake_incomplete(${PROJECT_NAME}_sl ${${PROJECT_NAME}_HEADERS_MD5} "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_DIR}")

add_library(${PROJECT_NAME}_dl SHARED ${${PROJECT_NAME}_HEADERS} ${${PROJECT_NAME}_SOURCES})
list(APPEND ${PROJECT_NAME}_TARGETS ${PROJECT_NAME}_dl)
check_if_cmake_incomplete(${PROJECT_NAME}_dl ${${PROJECT_NAME}_HEADERS_MD5} "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_DIR}")
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  set_target_properties(${PROJECT_NAME}_dl PROPERTIES
    OUTPUT_NAME "${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}-$<PLATFORM_ID>-$(Platform)-$<CONFIG>"
  )
else()
  set_target_properties(${PROJECT_NAME}_dl PROPERTIES
    OUTPUT_NAME "${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}-$<PLATFORM_ID>-${CMAKE_SYSTEM_PROCESSOR}-$<CONFIG>"
  )
endif()

# Check headers for C++ Modules support
if(MSVC AND MSVC_VERSION VERSION_GREATER 1900)  # VS2015
  # Parse the front of each header file looking for ^import .*;
  # todo
endif()

include(BoostLitePrecompiledHeader)
# Now the config is ready, generate a private precompiled header for
# ${PROJECT_NAME}_INTERFACE and have the sources in ${PROJECT_NAME}_SOURCES
# use the precompiled header UNLESS there is only one source file
# 
# todo
