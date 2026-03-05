cmake_minimum_required(VERSION 3.16)

project(ProVault VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)

qt_standard_project_setup(REQUIRES 6.5)

set(SOURCES
    "src/Source/main.cpp"
    "src/Source/applicationresources.cpp"
    "src/Source/qaesencryption.cpp"
    "src/Source/vaultmodel.cpp"
)

set(HEADERS
    "src/Header/applicationresources.h"
    "src/Header/qaesencryption.h"
    "src/Header/vaultmodel.h"
    "src/Header/vaultcredentials.h"
)

qt6_add_resources(RESOURCES res.qrc)

add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${RESOURCES})
message(${PROJECT_NAME})



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

target_include_directories (${PROJECT_NAME}
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/Header"
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt6::Quick Qt6::Widgets
)

source_group("/" FILES
    ${SOURCES} ${HEADERS}
)
