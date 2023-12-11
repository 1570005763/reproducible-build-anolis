#!/bin/bash

PKG_LEVEL="l1"

SRPM_DIR="$(pwd)/pkgs/$PKG_LEVEL/"
BUILD_OUTPUT_DIR="$(pwd)/output/$PKG_LEVEL/"
RESULT_DIFF_DIR="$(pwd)/result_diff/$PKG_LEVEL/"
SUMMARY_DIR="$(pwd)/summary/$PKG_LEVEL/"
BUILD_SCRIPT="$(pwd)/build_pkgs.sh"

# curidx=0

# pending_pkgs=("anaconda" "audit" "cracklib" "e2fsprogs" "llvm" "openssh" "sqlite" "tcl" "xfsprogs")
# nocheck_pkgs=()
# force_unsafe_pkgs=()

# start_with_item_in_list() {
#     local str="$1"
#     local list="$2"

#     for item in "${list[@]}"
#     do
#         if [ "$str" =~ "$item" ]
#         then
#             do_start_with=true
#             exit 0
#         fi
#     done

#     do_start_with=false
# }

do_work() {
    _SRPM_DIR=$1
    _BUILD_OUTPUT_DIR=$2
    _RESULT_DIFF_DIR=$3
    _SUMMARY_DIR=$4
    _BUILD_SCRIPT=$5
    _entry=$6

    # build for the first time
    bash $(pwd)/run_docker.sh --debug --srpm "${_SRPM_DIR}${_entry}" --script "${_BUILD_SCRIPT}" --output "${_BUILD_OUTPUT_DIR}${_entry}/1st/"

    # build for the second time
    bash $(pwd)/run_docker.sh --debug --srpm "${_SRPM_DIR}${_entry}" --script "${_BUILD_SCRIPT}" --output "${_BUILD_OUTPUT_DIR}${_entry}/2nd/"

    # compare outputs
    rm -rf ${_RESULT_DIFF_DIR}${_entry}.diff
    /usr/local/bin/diffoscope --output-empty --exclude-directory-metadata yes --html-dir "${_RESULT_DIFF_DIR}${_entry}.diff" "${_BUILD_OUTPUT_DIR}${_entry}/1st/RPMS" "${_BUILD_OUTPUT_DIR}${_entry}/2nd/RPMS"
}

i=0
for entry in $(ls ${SRPM_DIR}); do
    i=$((i+1))

    # run specific package
    # [[ ! $entry =~ "lvm2-" ]] && continue

    # run package from a certain index
    echo "$i. building $entry ..."
    # [[ $n -lt $curidx ]] && echo "skipping" && continue

    while true; do
        sleep 10
        running_work_num=$(docker ps --format '{{.Names}}' | grep "anolis23_rb_" | wc -l)
        if [[ "$running_work_num" -lt 10 ]]; then
            break
        fi
    done


    do_work $SRPM_DIR $BUILD_OUTPUT_DIR $RESULT_DIFF_DIR $SUMMARY_DIR $BUILD_SCRIPT $entry &

    # # build for the first time
    # bash $(pwd)/run_docker.sh --debug --srpm "${SRPM_DIR}${entry}" --script "${BUILD_SCRIPT}" --output "${BUILD_OUTPUT_DIR}${entry}/1st/"

    # # build for the second time
    # bash $(pwd)/run_docker.sh --debug --srpm "${SRPM_DIR}${entry}" --script "${BUILD_SCRIPT}" --output "${BUILD_OUTPUT_DIR}${entry}/2nd/"

    # # compare outputs
    # rm -rf ${RESULT_DIFF_DIR}${entry}.diff
    # /usr/local/bin/diffoscope --output-empty --exclude-directory-metadata yes --html-dir "${RESULT_DIFF_DIR}${entry}.diff" "${BUILD_OUTPUT_DIR}${entry}/1st/RPMS" "${BUILD_OUTPUT_DIR}${entry}/2nd/RPMS"

    # break
done