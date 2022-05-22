# Xbox360 USB Gamepad Userspace Driver
# Copyright (C) 2015 Ingo Ruhnke <grumbel@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.14)
project(virtualkeyboard)

option(BUILD_TESTS "Build tests" OFF)
option(WARNINGS "Switch on extra warnings" OFF)
option(WERROR "Turn warnings into errors" OFF)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WARNINGS)
  set(WARNINGS_CXX_FLAGS ${WARNINGS_CXX_FLAGS}
    -pedantic -Wall -Wextra -Wno-c++0x-compat -Wnon-virtual-dtor -Weffc++
    -Wshadow -Wcast-qual -Winit-self -Wno-unused-parameter
    -Wconversion -Wno-sign-conversion)
  # -Winline -Wfloat-equal -Wunreachable-code
endif()

if(WERROR)
  set(WARNINGS_CXX_FLAGS ${WARNINGS_CXX_FLAGS}
    -Werror)
endif()

set(XBOXDRV_BINDIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Install location for executables")
set(XBOXDRV_MANDIR "${CMAKE_INSTALL_PREFIX}/share/man" CACHE PATH "Install location for datafiles")

find_package(Threads REQUIRED)
find_package(X11 REQUIRED)

find_package(PkgConfig)
find_package(Python REQUIRED)
find_package(fmt REQUIRED)
pkg_search_module(GTK REQUIRED gtk+-3.0 IMPORTED_TARGET)
pkg_search_module(USB REQUIRED libusb-1.0 IMPORTED_TARGET)
pkg_search_module(UDEV REQUIRED libudev IMPORTED_TARGET)
pkg_search_module(DBUSGLIB REQUIRED dbus-glib-1 IMPORTED_TARGET)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/src)

function(build_dependencies)
  set(BUILD_TESTS OFF)
  find_package(argparser)
  if(NOT TARGET argparser::argparser)
    add_subdirectory(external/argparser/)
  endif()

  find_package(uinpp)
  if(NOT TARGET uinpp::uinpp)
    add_subdirectory(external/uinpp/)
  endif()

  find_package(logmich QUIET)
  if(NOT TARGET logmich::logmich)
    add_subdirectory(external/logmich/ EXCLUDE_FROM_ALL)
  endif()
endfunction()
build_dependencies()

file(GLOB VIRTUALKEYBOARD_SOURCES_CXX RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  src/*.cpp)
add_executable(virtualkeyboard ${VIRTUALKEYBOARD_SOURCES_CXX})
set_target_properties(virtualkeyboard PROPERTIES
  CXX_STANDARD 20
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS OFF)
target_link_libraries(virtualkeyboard
  logmich::logmich
  argparser::argparser
  uinpp::uinpp
  PkgConfig::GTK)

install(
  TARGETS virtualkeyboard
  RUNTIME DESTINATION ${XBOXDRV_BINDIR})
install(
  FILES doc/xboxdrv.1 doc/virtualkeyboard.1
  DESTINATION ${XBOXDRV_MANDIR}/man1)

# EOF #
