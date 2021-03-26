# 是否显示编译细节
set(CMAKE_VERBOSE_MAKEFILE OFF)

# 编译类型
set(CMAKE_BUILD_TYPE debug)
#set(CMAKE_BUILD_TYPE release)

##=============================================================================================
# 自定义宏


# 获取SVN 版本号
#find_package(Subversion)
#if(SUBVERSION_FOUND)
#	Subversion_WC_INFO(${PROJECT_SOURCE_DIR} Project)
#	#message("Current revision is ${Project_WC_REVISION}")
#	Subversion_WC_LOG(${PROJECT_SOURCE_DIR} Project)
#	#message("Last changed log is ${Project_LAST_CHANGED_LOG}")
#	add_definitions(-DSVNVERSION="${Project_WC_REVISION}")
#endif()
execute_process(
    COMMAND bash "-c" "svnversion -c | sed 's/^.*://' | sed 's/[A-Z]*$//' "
    OUTPUT_VARIABLE SVNVERSION
)
if(NOT SVNVERSION)
    if($ENV{GSVN})
        message(STATUS "will use global svn: $ENV{GSVN}")
        string(STRIP $ENV{GSVN} SVNVERSION)
        add_definitions(-DSVNVERSION="${SVNVERSION}")
    else()
        message(STATUS "can not get svn info ...")
    endif()
else()
    string(STRIP ${SVNVERSION} SVNVERSION)
    add_definitions(-DSVNVERSION="${SVNVERSION}")
endif()

set(CMAKE_C_COMPILER "aarch64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "aarch64-linux-gnu-g++")
