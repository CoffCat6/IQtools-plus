include_guard(GLOBAL)

find_package(Git QUIET)

set(IQTOOLS_GIT_DESCRIBE "${PROJECT_VERSION}")

if(Git_FOUND)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" describe --tags --always --dirty
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE IQTOOLS_GIT_DESCRIBE
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(NOT IQTOOLS_GIT_DESCRIBE)
        set(IQTOOLS_GIT_DESCRIBE "${PROJECT_VERSION}")
    endif()
endif()

message(STATUS "IQtoolsPlus git version: ${IQTOOLS_GIT_DESCRIBE}")
