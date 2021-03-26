# 设置项目名称
project(hello C CXX)

SET(CMAKE_SYSTEM_NAME Linux)
#set(CMAKE_SYSTEM_PROCESSOR arm)

# 设置默认变量
set(CMAKE_VERBOSE_MAKEFILE ON) #显示编译细节
set(CMAKE_BUILD_TYPE debug) #编译类型


if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL  arm )
	message(STATUS "include rules.cmake ${CMAKE_SYSTEM_PROCESSOR}")
	include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/rules.cmake)
endif()	

# 输出文件路径，相对于当前路径。set output directories
if(NOT OUT_DIR)
    set(OUT_DIR out)
endif()

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DFILENAME='\"$(notdir $(abspath $<))\"' ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -fpermissive") #使用c11编译选项 set(CMAKE_CXX_STANDARD 11)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DFILENAME='\"$(notdir $(abspath $<))\"' ")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DIR}/${PLATFORM_TYPE})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DIR}/${PLATFORM_TYPE})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DIR}/${PLATFORM_TYPE})

add_compile_options(-O2)

# 设置 C/C++ 的编译选项
# set(CMAKE_C_FLAGS "-mcpu=cortex-a7 -mfloat-abi=softfp -mfpu=neon-vfpv4 -mno-unaligned-access -fno-aggressive-loop-optimizations -DUSE_MAKEFILE -std=c99 ${CMAKE_C_FLAGS}")
# set(CMAKE_CXX_FLAGS "-std=c99 ${CMAKE_C_FLAGS}")
#if(CMAKE_SYSTEM_PROCESSOR)
#	set(CMAKE_C_COMPILER "${PLATFORM_TYPE}-g++")
#	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu++11 -fpermissive -Wreturn-type")
#else
#		
#endif


# 添加子模块
###################################################################################################
# 设置子模块 如果存在，设置。路径在modules目录下。
# 为了使module子模块先编译需要设置依赖关系，module下子文件夹名称必须和module子模块的输出名称相同 BsLog子文件夹输出为 BsLog
set(META_MODULE_LIST
    #modules/bsshmsrc
)
foreach(module ${META_MODULE_LIST})
    message(STATUS " copy current 'rules.cmake' 'CMakeLists.txt' 'Makefile' to sub module '${module}' ...")
    #file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/cmake/rules.cmake DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${module}/cmake/)
    #file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${module}/)
    #file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/Makefile DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${module}/)
endforeach()
add_modules()

# 生成可执行程序
###################################################################################################
# 设置可执行程序文件名 不可与重复其它 library 或者其它 exe 文件名重复
set(META_PROJECT_NAME ${PROJECT_NAME})

# 设置头文件路径，相对路径和绝对路径均可。
set(META_INCLUDE_PATH
    inc
    # other include find_path
)

# 包含的c或者cpp文件。两种方法均可。
# 包含src目录下及其子目录所有c或cpp,包含子文件夹下的文件,单独指定不包含哪些文件
file(GLOB_RECURSE META_SRC_LISTS 
    src/*.c 
    src/*.cpp
)

# 依次列出需要包含的文件。
# set(META_SRC_LISTS
#     ${CMAKE_CURRENT_SOURCE_DIR}/src/a.c 
#     ${CMAKE_CURRENT_SOURCE_DIR}/src/b.c
# )

# 单独指定不包含哪些文件
# list(REMOVE_ITEM META_SRC_LISTS
#     ${CMAKE_CURRENT_SOURCE_DIR}/src/a.c 
# )

# 设置依赖库查找路径
set(META_LIB_PATH
	${CMAKE_CURRENT_SOURCE_DIR}/../Deps/libs
	# other lib find_path  
)

# 需要连接的库。三种写法都可以，每行一个库。
set(META_DEP_LISTS
    # libpthread.so 
    # pthread 
    # -pthread
    # -lpthread
    # libmpi.a
	pthread
)
build_exe()



