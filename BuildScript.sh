#!/bin/sh

#  BuildScript.sh
#
#  Created by Mikk Rätsep on 16/11/2017.
#  Copyright © 2017 High-Mobility. All rights reserved.


DEVICE_ONLY=false

if [[ $1 == "-deviceOnly" ]]; then
    DEVICE_ONLY=true
fi


######################
# Options
######################

CONFIGURATION="Release"
BUILD_DIR="build"

FRAMEWORK_NAME="AMVKit"

SIMULATOR_PATH="${BUILD_DIR}/${CONFIGURATION}-simulator"
SIMULATOR_LIBRARY_PATH="${SIMULATOR_PATH}/${FRAMEWORK_NAME}.framework"

DEVICE_PATH="${BUILD_DIR}/${CONFIGURATION}-device"
DEVICE_LIBRARY_PATH="${DEVICE_PATH}/${FRAMEWORK_NAME}.framework"

ARCHIVE_PATH="${DEVICE_PATH}/${FRAMEWORK_NAME}.xcarchive"

UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iosUniversal"

FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"


######################
# Build Frameworks
######################

echo "Archiving for Device..."
xcodebuild -quiet -scheme "${FRAMEWORK_NAME}" -sdk iphoneos -archivePath "${ARCHIVE_PATH}" clean archive

if [[ $DEVICE_ONLY == false ]]; then
    echo "Building for Simulator..."
    xcodebuild -quiet -target "${FRAMEWORK_NAME}" -sdk iphonesimulator CONFIGURATION_BUILD_DIR="${SIMULATOR_PATH}" ONLY_ACTIVE_ARCH=NO clean build
fi

# Updates the device's library path
DEVICE_LIBRARY_PATH="${ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework"


######################
# Create directory for universal
######################

echo "Removing and making directories..."
rm -rf ${UNIVERSAL_LIBRARY_DIR}
rm -rf ${FRAMEWORK}

mkdir ${UNIVERSAL_LIBRARY_DIR}
mkdir ${FRAMEWORK}


######################
# Copy files Framework
######################

echo "Copying frameworks..."
cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"

# And the AppStoreCompatible script
if [[ $DEVICE_ONLY == false ]]; then
    echo "Copying AppStoreCompatible script"
    cp "${FRAMEWORK_NAME}/Supporting/AppStoreCompatible.sh" "${FRAMEWORK}"
fi


######################
# Make an Universal binary
######################

if [[ $DEVICE_ONLY == false ]]; then
    echo "Combining frameworks together..."
    lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}"
fi

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
    cp -f -R "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/"
fi

if [[ $DEVICE_ONLY == false ]]; then
    if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
        cp -f -R "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/"
    fi
fi

# Copies the Universal framework to ROOT
echo "Coping framework to ROOT..."
cp -f -R "${FRAMEWORK}" ""

# Removes the build/ folder from the source folder
echo "Removing build directory..."
rm -rfd "build"



