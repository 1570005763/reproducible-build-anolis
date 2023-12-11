#!/bin/bash

basedir="./pkgs/$level/"
logdir="./build_log/$level/"

pending_pkgs=("anaconda" "audit" "cracklib" "e2fsprogs" "llvm" "openssh" "sqlite" "tcl" "xfsprogs")
nocheck_pkgs=()
force_unsafe_pkgs=()


start_with_item_in_list() {
    local str="$1"
    local list="$2"

    for item in "${list[@]}"
    do
        if [ "$str" =~ "$item" ]
        then
            do_start_with=true
            exit 0
        fi
    done

    do_start_with=false
}

srpm_files=(*.src.rpm)
if [ "${#srpm_files[@]}" -eq 1 ]; then
    srpm_file=${srpm_files[0]}
else
    echo "srpm file invalid" >&2
    exit 1
fi

echo "building $srpm_file ..."

# export FORCE_UNSAFE_CONFIGURE=1

dnf clean all > "./output/$srpm_file.log" 2>&1
dnf builddep -y "$srpm_file" > "./output/$srpm_file.log" 2>&1
# rpm -i $entry

# if { start_with_item_in_list $entry pending_pkgs; [ do_start_with] }; then
#     echo "优秀"
# elif [ $score -ge 80 ]; then
#     echo "良好"
# elif [ $score -ge 70 ]; then
#     echo "中等"
# else
#     echo "不及格"
# fi

# rpmbuild --rebuild $srpm_file > "./output/$srpm_file.log" 2>&1
rpmbuild --rebuild --nocheck \
    --define "source_date_epoch_from_changelog Y" \
    --define "clamp_mtime_to_source_date_epoch Y" \
    --define "use_source_date_epoch_as_buildtime Y" \
    $srpm_file > "./output/$srpm_file.log" 2>&1


# [[ `cat ${logdir}/${entry}` =~ "error: " ]] && echo ${entry} >> ./pkgs/${level}_error_log.txt

# unset FORCE_UNSAFE_CONFIGURE

rm -rf ./output/RPMS && mkdir ./output/RPMS
mv ~/rpmbuild/RPMS/* ./output/RPMS/
