#!/bin/bash

REGISTRY_PREFIX="registry.cn-hangzhou.aliyuncs.com/1ch0/"
IMAGES_FILE="images.txt"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# 检查 images.text 文件是否存在
if [ ! -f "$IMAGES_FILE" ]; then
    echo "Error: $IMAGES_FILE not found in the current directory."
    exit 1
fi

# 读取并处理每一行
while IFS= read -r image || [[ -n "$image" ]]; do
    # 跳过空行
    if [ -z "$image" ]; then
        continue
    fi

    echo "Processing image: $image"

    # 构建源镜像名称
    source_image="${REGISTRY_PREFIX}${image}"

    # 拉取镜像
    echo "Pulling image: $source_image"
    if ! docker pull "$source_image"; then
        echo "Error: Failed to pull image $source_image"
        continue
    fi

    # 重新标记镜像
    echo "Retagging image: $source_image -> $image"
    if ! docker tag "$source_image" "$image"; then
        echo "Error: Failed to retag image $source_image to $image"
        continue
    fi

    # 删除原始镜像
    echo "Removing original image: $source_image"
    if ! docker rmi "$source_image"; then
        echo "Warning: Failed to remove original image $source_image"
    fi

    echo "Successfully processed image: $image"
    echo "------------------------------------"
done < "$IMAGES_FILE"

echo "All images have been processed."
