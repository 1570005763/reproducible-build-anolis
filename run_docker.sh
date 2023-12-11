#!/bin/bash

# set default value
debug_mode=0
srpm_file=""
script_file=""
output_dir="./"

# parse command line options
PARSED_OPTIONS=$(getopt -n "$0" -o d --long debug,srpm:,script:,output: -- "$@")

# exit if parse failed
if [ $? -ne 0 ]; then
    echo "Failed to parse options." >&2
    exit 1
fi

eval set -- "$PARSED_OPTIONS"

while true; do
    case "$1" in
        -d | --debug)
            debug_mode=1
            shift
            ;;
        --srpm)
            srpm_file="$2"
            shift 2
            ;;
        --script)
            script_file="$2"
            shift 2
            ;;
        --output)
            output_dir="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unsupported option: $1" >&2
            exit 1
            ;;
    esac
done

echo "Srpm name: $srpm_file"
echo "Script name: $script_file"
echo "Output dir: $output_dir"
echo "Debug mode: $debug_mode"

# Docker容器的名称和镜像
CONTAINER_NAME="anolis23_rb_$(basename ${srpm_file} .an23.src.rpm)"
IMAGE_NAME="anolis23" # 构建使用的标准镜像名

docker run --privileged --network=host --rm \
    --name $CONTAINER_NAME \
    -v "${srpm_file}:/home/$(basename ${srpm_file})" \
    -v "${script_file}:/home/$(basename ${script_file})" \
    -v "${output_dir}:/home/output/" \
    $IMAGE_NAME \
    /bin/bash -c "cd /home && ./$(basename ${script_file}) ${srpm_file}"
