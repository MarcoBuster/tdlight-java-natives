#!/bin/bash -e
# REQUIRED PARAMETERS:
# OPERATING_SYSTEM_NAME = <windows | linux | osx>
# CPU_ARCHITECTURE_NAME = <amd64 | aarch64>
# IMPLEMENTATION_NAME = <tdlib | tdlight>
# CPU_CORES = <cores>
# CMAKE_EXTRA_ARGUMENTS = <args>

# Check variables correctness
if [ -z "${OPERATING_SYSTEM_NAME}" ]; then
	echo "Missing parameter: OPERATING_SYSTEM_NAME"
	exit 1
fi
if [ -z "${CPU_ARCHITECTURE_NAME}" ]; then
	echo "Missing parameter: CPU_ARCHITECTURE_NAME"
	exit 1
fi
if [ -z "${IMPLEMENTATION_NAME}" ]; then
	echo "Missing parameter: IMPLEMENTATION_NAME"
	exit 1
fi
if [ -z "${CPU_CORES}" ]; then
	echo "Missing parameter: CPU_CORES"
	exit 1
fi

cd ../

# Print details
echo "Generating TdApi.java..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/tdapi_java_build/ ] && rm -r ./generated/tdapi_java_build/
[ -d ./generated/tdjni_build/ ] && rm -r ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] && rm -r ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] && rm -r ./generated/tdjni_docs/
[ -d ./generated/src/main/jni-cpp-src/ ] && rm -r ./generated/src/main/jni-cpp-src/
[ -d ./generated/src/main/jni-java-src/ ] && rm -r ./generated/src/main/jni-java-src/
[ -f ./generated/src/main/java/it/tdlight/jni/TdApi.java ] && rm ./generated/src/main/java/it/tdlight/jni/TdApi.java

# Create missing folders
echo "Creating missing folders..."
[ -d ./generated/tdapi_java_build/ ] || mkdir ./generated/tdapi_java_build/
[ -d ./generated/tdjni_build/ ] || mkdir ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] || mkdir ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] || mkdir ./generated/tdjni_docs/

# Copy source files
echo "Copying source files..."
cp -r ./src/main/jni-cpp-src/common/. ./generated/src/main/jni-cpp-src
cp -r ./src/main/jni-cpp-src/${IMPLEMENTATION_NAME}/. ./generated/src/main/jni-cpp-src
cp -r ./src/main/jni-java-src ./generated/src/main/jni-java-src

# Configure cmake
echo "Configuring CMake..."
cd ./generated/tdapi_java_build/
echo "Telegram source path: '$(realpath ../implementation/)'"
cmake -DCMAKE_BUILD_TYPE=Release \
 -DTD_SRC_DIR=$(realpath ../implementation/) \
 -DTD_GENERATED_BINARIES_DIR=$(realpath ../td_tools/td/generate) \
 -DTd_DIR=$(realpath ../td_bin/lib/cmake/Td/) \
 -DTDNATIVES_BIN_DIR=$(realpath ../tdjni_bin/) \
 -DTDNATIVES_DOCS_BIN_DIR=$(realpath ../tdjni_docs/) \
 -DJAVA_SRC_DIR=$(realpath ../src/main/jni-java-src/) \
 ${CMAKE_EXTRA_ARGUMENTS} \
 $(realpath ../src/main/jni-cpp-src/)

# Run cmake to generate TdApi.java
echo "Generating TdApi.java..."
cmake --build . --target td_generate_java_api --config Release ${CPU_CORES}
cd ..

echo "Patching TdApi.java..."
python3 ../tdlib-serializer/ $(realpath ./src/main/jni-java-src/it/tdlight/jni/TdApi.java) $(realpath ./src/main/jni-java-src/it/tdlight/jni/new_TdApi.java) $(realpath ../tdlib-serializer/headers.txt)
rm ./src/main/jni-java-src/it/tdlight/jni/TdApi.java
unexpand --tabs=2 ./src/main/jni-java-src/it/tdlight/jni/new_TdApi.java > ./src/main/jni-java-src/it/tdlight/jni/TdApi.java
rm ./src/main/jni-java-src/it/tdlight/jni/new_TdApi.java
cp ./src/main/jni-java-src/it/tdlight/jni/TdApi.java ./src/main/java/it/tdlight/jni/TdApi.java

echo "Generated '$(realpath ./src/main/java/it/tdlight/jni/TdApi.java)'"

echo "Done."
exit 0