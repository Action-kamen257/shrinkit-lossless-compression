cmake_minimum_required(VERSION 3.16)
project(ShrinkIt VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable Qt moc processing
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Output binaries to bin/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Compiler warnings and optimizations
if(MSVC)
    add_compile_options(/W4 /O2 /permissive- /utf-8)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -O3)
endif()

# Core include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qt_bridge
)

# Core library source files
set(CORE_SOURCES
    src/core/HuffmanNode.h
    src/core/MinHeap.h
    src/core/BitCode.h
    src/core/BitStream.h
    src/core/BitStream.cpp
    src/core/Checksum.h
    src/core/FileFormat.h
    src/core/LZ77.h
    src/core/CompressionStats.h
    src/core/HuffmanTree.h
    src/core/HuffmanTree.cpp
    src/core/HuffmanCompressor.h
    src/core/HuffmanCompressor.cpp
)

add_library(shrinkit_core STATIC ${CORE_SOURCES})
target_include_directories(shrinkit_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/core)

# Command-line interface executable
add_executable(shrinkit_cli src/cli/main_cli.cpp)
target_link_libraries(shrinkit_cli PRIVATE shrinkit_core)

# Test suite executable
add_executable(shrinkit_tests src/tests/test_huffman.cpp)
target_link_libraries(shrinkit_tests PRIVATE shrinkit_core)

# Qt 6 GUI target
find_package(Qt6 QUIET COMPONENTS Core Gui Quick Qml QuickControls2)

if(Qt6_FOUND)
    message(STATUS "Qt 6 found (${Qt6_VERSION})! Enabling ShrinkIt Qt GUI application.")

    set(GUI_SOURCES
        src/qt_bridge/CompressionWorker.h
        src/qt_bridge/CompressionWorker.cpp
        src/qt_bridge/ShrinkItEngine.h
        src/qt_bridge/ShrinkItEngine.cpp
        src/main.cpp
    )

    if(WIN32)
        list(APPEND GUI_SOURCES src/ui/assets/app_icon.rc)
    endif()

    qt_add_executable(shrinkit_gui ${GUI_SOURCES})
    target_include_directories(shrinkit_gui PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/ui/assets")
    target_link_libraries(shrinkit_gui PRIVATE shrinkit_core Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)

    qt_add_resources(shrinkit_gui "shrinkit_resources"
        PREFIX "/"
        BASE "src"
        FILES
            src/ui/qml/qmldir
            src/ui/qml/Main.qml
            src/ui/qml/Theme.qml
            src/ui/assets/logo.svg
            src/ui/assets/app_icon.png
            src/ui/assets/app_icon.ico
            src/ui/qml/components/ShrinkItLogo.qml
            src/ui/qml/components/LucideIcon.qml
            src/ui/qml/components/GlassSegmentedControl.qml
            src/ui/qml/components/ComparisonBarChart.qml
            src/ui/qml/components/AppSidebar.qml
            src/ui/qml/components/GlassMaterial.qml
            src/ui/qml/components/GlassCard.qml
            src/ui/qml/components/GlassButton.qml
            src/ui/qml/components/GlassSlider.qml
            src/ui/qml/components/GlassToggle.qml
            src/ui/qml/components/GlassProgressBar.qml
            src/ui/qml/views/OverviewView.qml
            src/ui/qml/views/CompressView.qml
            src/ui/qml/views/DecompressView.qml
    )
else()
    message(STATUS "Qt 6 not found in build environment. Building ShrinkIt Core C++ Backend, CLI and Test Suite.")
endif()
