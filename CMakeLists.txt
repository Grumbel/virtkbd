# virtkbd - Virtual On-Screen Keyboard
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
project(virtkbd)

# Modules
set(TINYCMMC_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/external/cmake-modules/modules/")
find_package(tinycmmc CONFIG)
message(STATUS "tinycmmc module path: ${TINYCMMC_MODULE_PATH}")
list(APPEND CMAKE_MODULE_PATH ${TINYCMMC_MODULE_PATH})

include(GNUInstallDirs)
include(MaximumWarnings)
include(GetProjectVersion)
message(STATUS "Version: ${PROJECT_NAME} ${PROJECT_VERSION}")

# Dependencies
find_package(PkgConfig)
pkg_search_module(GTK REQUIRED gtk+-3.0 IMPORTED_TARGET)

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

# Program
file(GLOB VIRTKBD_SOURCES_CXX RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  src/*.cpp)
add_executable(virtkbd ${VIRTKBD_SOURCES_CXX})
target_compile_options(virtkbd PRIVATE ${WARNINGS_CXX_FLAGS} -Wno-deprecated-declarations)
set_target_properties(virtkbd PROPERTIES
  CXX_STANDARD 20
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS OFF)
target_link_libraries(virtkbd
  logmich::logmich
  argparser::argparser
  uinpp::uinpp
  PkgConfig::GTK)

install(TARGETS virtkbd
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES doc/virtkbd.1
  DESTINATION "${CMAKE_INSTALL_MANDIR}/man1")

# EOF #
