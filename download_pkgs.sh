#!/bin/bash

# basedir="./pkgs/l1/"
# listname="l1_pkg_list.txt"
basedir="./pkgs/l2/"
listname="l2_pkg_list.txt"

n=1
cat ./pkgs/$listname | while read line
do
    echo "$n. downloading $line ..."
    # wget $baseurl$line -P $basedir
    dnf download --source $line --destdir=$basedir
    n=$((n+1))
done