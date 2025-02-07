cmake_minimum_required(VERSION 3.10)

project(hacktv)

# Set version
execute_process(COMMAND git log -1 --pretty='%cd' --date=format:'%Y%m%d' OUTPUT_VARIABLE GIT_DATE)
execute_process(COMMAND git describe --dirty --always OUTPUT_VARIABLE GIT_DESCRIBE)
set(VERSION "${GIT_DATE}-${GIT_DESCRIBE}")

# Set the compiler
set(CMAKE_C_COMPILER ${CROSS_HOST}gcc)
set(CMAKE_C_FLAGS "-g -Wall -pthread -O3 ${EXTRA_CFLAGS} -DVERSION=\"${VERSION}\"")
set(CMAKE_EXE_LINKER_FLAGS "-g -lm -pthread ${EXTRA_LDFLAGS}")

# Define the source files
set(OBJS
    hacktv.c
    common.c
    fir.c
    vbidata.c
    teletext.c
    wss.c
    video.c
    fifo.c
    mac.c
    dance.c
    eurocrypt.c
    videocrypt.c
    videocrypts.c
    syster.c
    acp.c
    vits.c
    vitc.c
    nicam728.c
    sis.c
    av.c
    av_test.c
    av_ffmpeg.c
    rf.c
    rf_file.c
    spdif.c
)

# Set the required packages
find_package(PkgConfig REQUIRED)

# Set the packages to search
set(PKG_LIST
    libavcodec
    libavformat
    libavdevice
    libswscale
    libswresample
    libavutil
    ${EXTRA_PKGS}
)

# Add the pkg-config flags
foreach(pkg IN LISTS PKG_LIST)
    pkg_check_modules(${pkg} REQUIRED ${pkg})
    list(APPEND CMAKE_C_FLAGS ${${pkg}_CFLAGS})
    list(APPEND CMAKE_EXE_LINKER_FLAGS ${${pkg}_LIBRARIES})
endforeach()

# Check for optional packages
find_package(PkgConfig QUIET)
pkg_check_modules(HACKRF REQUIRED libhackrf)
if(HACKRF_FOUND)
    list(APPEND OBJS rf_hackrf.c)
    list(APPEND CMAKE_C_FLAGS -DHAVE_HACKRF)
    list(APPEND CMAKE_EXE_LINKER_FLAGS ${HACKRF_LIBRARIES})
endif()

pkg_check_modules(SOAPYSDR REQUIRED SoapySDR)
if(SOAPYSDR_FOUND)
    list(APPEND OBJS rf_soapysdr.c)
    list(APPEND CMAKE_C_FLAGS -DHAVE_SOAPYSDR)
    list(APPEND CMAKE_EXE_LINKER_FLAGS ${SOAPYSDR_LIBRARIES})
endif()

pkg_check_modules(FL2K REQUIRED libosmo-fl2k)
if(FL2K_FOUND)
    list(APPEND OBJS rf_fl2k.c)
    list(APPEND CMAKE_C_FLAGS -DHAVE_FL2K)
    list(APPEND CMAKE_EXE_LINKER_FLAGS ${FL2K_LIBRARIES})
endif()

# Include the pkg-config flags
list(APPEND CMAKE_C_FLAGS ${PKGCONF_CFLAGS})
list(APPEND CMAKE_EXE_LINKER_FLAGS ${PKGCONF_LIBRARIES})

# Create the executable
add_executable(hacktv ${OBJS})

# Install the executable
install(TARGETS hacktv DESTINATION ${PREFIX}/usr/bin/)

# Clean command
add_custom_target(clean
    COMMAND ${CMAKE_COMMAND} -E remove *.o *.d hacktv hacktv.exe
)

# Include the dependencies
set_target_properties(hacktv PROPERTIES LINK_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
