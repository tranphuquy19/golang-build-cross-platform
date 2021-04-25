#!/bin/bash

# Chúng ta sẽ pass tên ứng dụng thông qua cli, vd: bash ./build.sh hello-world
APP_NAME_ARG=$1
APP_NAME="${APP_NAME_ARG:-go-app}"

WORKING_DIR="${PWD}"

PLATFORMS_FILE="platforms.txt"
FULL_PATH_PLATFORMS_FILE=$WORKING_DIR/$PLATFORMS_FILE

# check file platforms.txt
if [ ! -f $FULL_PATH_PLATFORMS_FILE ]; then
    echo "Platforms file: $FULL_PATH_PLATFORMS_FILE does not exist"
    exit 1
fi

# Xóa folder build
echo "Clean build folder"
rm -rf ./build

# Tạo folder build
echo "Create build folder"
mkdir -p build

# install dependencies
echo "Install dependencies"
go mod download

# Đọc file platforms.txt
while read line; do
    platform_split=(${line//\// }) # Tương tự "linux/arm".split("/") Javascript

    GOOS=${platform_split[0]}
    GOARCH=${platform_split[1]}

    output_name=$APP_NAME

    # Đối với OS=windows thì sẽ thêm đuôi .exe
    if [ $GOOS = "windows" ]; then
        output_name+='.exe'
    fi

    mkdir -p build/$GOOS/$GOARCH
    output_path="$WORKING_DIR/build/$GOOS/$GOARCH/$output_name"

    echo "====================================================" #Separator
    echo "Building for OS=$GOOS Architecture=$GOARCH" 
    
    env GOOS=$GOOS GOARCH=$GOARCH go build -ldflags="-s -w" -o $output_path

    if [ ! -f $output_path ]; then
        echo "Failed when build for OS=$GOOS Architecture=$GOARCH"
        exit 1
    else
        fileSize=$(find "$output_path" -printf "%s")
        echo "Done with output file: $output_path ($fileSize bytes)"
    fi

    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi
done < $PLATFORMS_FILE

echo "DONE"