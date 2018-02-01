#!/bin/sh

######################
# Options
######################

FRAMEWORK_NAME="${PRODUCT_NAME}"

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

echo "Building for Simulator..."
xcodebuild -quiet -target ${PRODUCT_NAME} -sdk iphonesimulator -configuration ${CONFIGURATION} CONFIGURATION_BUILD_DIR=${SIMULATOR_PATH} ONLY_ACTIVE_ARCH=NO clean build

echo "Archiving for Device..."
xcodebuild -quiet -scheme ${PRODUCT_NAME} -sdk iphoneos -configuration ${CONFIGURATION} -archivePath ${ARCHIVE_PATH} clean archive

# Updates the device's library path
DEVICE_LIBRARY_PATH="${ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework"


######################
# Create directory for universal
######################

echo "Removing and making directories..."
rm -rf ${UNIVERSAL_LIBRARY_DIR}

mkdir ${UNIVERSAL_LIBRARY_DIR}
mkdir ${FRAMEWORK}


######################
# Copy files Framework
######################

echo "Copying frameworks..."
cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"

# And the AppStoreCompatible script
echo "Copying AppStoreCompatible script"
cp "${SRCROOT}/${FRAMEWORK_NAME}/Supporting/AppStoreCompatible.sh" "${FRAMEWORK}"


######################
# Make an Universal binary
######################

echo "Combining frameworks together..."
lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}"

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -f -R "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/"
fi

if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -f -R "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/"
fi

# Removes the build/ folder from the source folder
echo "Removing build directory..."
rm -rfd "${SRCROOT}/build"


######################
# Open the Universal folder
######################

open ${UNIVERSAL_LIBRARY_DIR}




