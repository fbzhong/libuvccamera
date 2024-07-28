#!/bin/sh

export GNUMAKE=gmake

ANDROID_NDK_ROOT=/Users/fbzhong/Library/Android/sdk/ndk/27.0.12077973/

# clean.
rm -rf src/main/obj

# build libjpeg-turbo
JPEG_TURBO_SRC=src/main/jni/libjpeg-turbo

pushd $JPEG_TURBO_SRC

# List of ABIs to build for
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
for ABI in "${ABIS[@]}"; do
    echo "Building for $ABI..."

    rm -rf CMakeFiles
    cmake \
        -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
        -DANDROID_NDK=$ANDROID_NDK_ROOT \
        -DANDROID_ABI=$ABI \
        -DANDROID_STL=none \
        -DCMAKE_BUILD_TYPE=Release \
        .

    make clean
    make -j8 turbojpeg-static

    if [ $? -ne 0 ]; then
        echo "Error building for $ABI"
        exit 1
    fi

    # Copy the built library to the jniLibs directory
    mkdir -p ../../prebuilt/$ABI
    cp libturbojpeg.a jconfig.h jconfigint.h jversion.h ../../prebuilt/$ABI/

    echo "Done building for $ABI"
done

popd

# build jni libs.
pushd src/main/jni
$ANDROID_NDK_ROOT/ndk-build
popd

echo "All done!"
