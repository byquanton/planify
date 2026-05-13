# Planify on Android

Current State: libical uses cmake and it doesn't like the pixiewood/meson env

```
pwd/to/gtk-android-builder/pixiewood -v prepare -a ~/.local/share/JetBrains/Toolbox/apps/android-studio -s ~/Android/Sdk/ build-aux/android/io.github.alainm23.planify.xml
```


Logs
```
Run-time dependency libical-glib found: NO (tried pkgconfig and cmake)
Looking for a fallback subproject for the dependency libical-glib

Executing subproject libical method cmake 

libical| Found CMake: /usr/bin/cmake (3.31.11)

| Configuring the build directory with CMake version 3.31.11
| Running CMake with: -G Ninja -DCMAKE_INSTALL_PREFIX=/ -DCMAKE_BUILD_TYPE=Debug
|   - build directory:          /home/me/Projects/planify-android/.pixiewood/bin-x86_64/subprojects/libical/__CMake_build
|   - source directory:         /home/me/Projects/planify-android/subprojects/libical
|   - toolchain file:           /home/me/Projects/planify-android/.pixiewood/bin-x86_64/subprojects/libical/__CMake_build/CMakeMesonToolchainFile.cmake
|   - preload file:             /usr/lib/python3.14/site-packages/mesonbuild/cmake/data/preload.cmake
|   - trace args:               --trace-expand --trace-format=json-v1 --no-warn-unused-cli --trace-redirect=cmake_trace.txt
|   - disabled policy warnings: [CMP0025, CMP0047, CMP0056, CMP0060, CMP0065, CMP0066, CMP0067, CMP0082, CMP0089, CMP0102]

| CMake Deprecation Warning at CMakeLists.txt:91 (cmake_minimum_required):
| Compatibility with CMake < 3.10 will be removed from a future version of
| CMake.

| Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
| to tell CMake that the project requires at least <min> but has been updated
| to work with policies introduced by <max> or earlier.

| Put cmake in trace mode, but with variables expanded.
| Put cmake in trace mode and sets the trace output format.
| Not searching for unused variables given on the command line.
| Put cmake in trace mode and redirect trace output to a file instead of stderr.
| Trace will be written to cmake_trace.txt

| CMake Error at /usr/share/cmake/Modules/Platform/Android-Determine.cmake:124 (message):
| The value of CMAKE_SYSROOT:

| /home/me/Android/Sdk/ndk/magisk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/

| does not match any of the forms:

| <ndk>/platforms/android-<api>/arch-<arch>
| <standalone-toolchain>/sysroot

| where:

| <ndk>  = Android NDK directory (with forward slashes)
| <api>  = Android API version number (decimal digits)
| <arch> = Android ARCH name (lower case)
| <standalone-toolchain> = Path to standalone toolchain prefix

| Call Stack (most recent call first):
| /usr/share/cmake/Modules/CMakeDetermineSystem.cmake:184 (include)
| CMakeLists.txt:92 (project)


| CMake Error: CMake was unable to find a build program corresponding to "Ninja".  CMAKE_MAKE_PROGRAM is not set.  You probably need to select a different build tool.
| -- Configuring incomplete, errors occurred!

libical| CMake configuration: FAILED

meson.build:47:14: ERROR: Failed to configure the CMake subproject: The value of CMAKE_SYSROOT:
   /home/me/Android/Sdk/ndk/magisk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/
 does not match any of the forms:
   <ndk>/platforms/android-<api>/arch-<arch>
   <standalone-toolchain>/sysroot
 where:
   <ndk>  = Android NDK directory (with forward slashes)
   <api>  = Android API version number (decimal digits)
   <arch> = Android ARCH name (lower case)
   <standalone-toolchain> = Path to standalone toolchain prefix


A full log can be found at /home/me/Projects/planify-android/.pixiewood/bin-x86_64/meson-logs/meson-log.txt
```