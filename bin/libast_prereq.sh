#!/usr/bin/env bash

# This script is used for feature detection and setting up other configurations that are required to build libast
set -x
set -e

# This script is run from an unspecified directory so we have to determine directory paths
# http://mesonbuild.com/Reference-manual.html#run_command
script_path=`realpath "$0"`
bin_dir=`dirname "$script_path"`
base_dir=`dirname "$bin_dir"`

PATH=$bin_dir:$PATH

# Legacy build system keeps files generated by iffe with different names under different directories
# Each array listed below is processed separately and headers generated by iffe are kept in separate directories
# in a way that is compatible with legacy build system
iffe_tests=( 'common' 'aso' 'ccode' 'iconv' 'vmalloc' )

iffe_tests_2=()

iffe_c_tests=()

iffe_c_tests_2=('sfinit.c' 'signal.c')

iffe_c_tests_3=()

iffe_sh_tests=()

iffe_sh_tests_2=()

iffe_sh_tests_3=()

mkdir $base_dir/src/lib/libast/features/FEATURE
$base_dir/src/lib/libast/features/siglist.sh > $base_dir/src/lib/libast/features/FEATURE/siglist

pushd "$base_dir/src/lib/libast/features"

for iffe_test in ${iffe_tests[@]}; do
    iffe -v -X ast -X std -c 'cc -D_BLD_DLL -D_BLD_ast' run $iffe_test

    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/ast_$iffe_test.h"
done

for iffe_test in ${iffe_tests_2[@]}; do
    iffe -v -X ast -X std -c 'cc -D_BLD_DLL -D_BLD_ast' run $iffe_test
    
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/$iffe_test.h"
done

"$bin_dir/conf" -v "$base_dir/src/lib/libast/comp/conf.tab" cc -I../include -D_BLD_DLL -D_BLD_ast

# iffe behaves strangely when I try to pass it a string made with double quotes
# I pass this function as an argument to iffe while processing .c files
function cc_fun {
    cc -D_BLD_DLL -D_BLD_ast -I. -I.. -Icomp -I../comp -Iinclude -I../include -Istd -I../std -I../features  "$@"
}

export -f cc_fun

for iffe_test in ${iffe_c_tests[@]}; do
    iffe -v -X ast -X std -c cc_fun run "$iffe_test"
    name=$(echo "$iffe_test" | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/ast_$name.h"
done

for iffe_test in ${iffe_c_tests_2[@]}; do
    iffe -v -X ast -X std -c cc_fun run $iffe_test
    name=$(echo "$iffe_test" | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/FEATURE/$name"
done

for iffe_test in ${iffe_c_tests_3[@]}; do
    iffe -v -X ast -X std -c cc_fun run "$iffe_test"
    name=$(echo $iffe_test | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/$name.h"
done

for iffe_test in ${iffe_sh_tests[@]}; do
    iffe -v -X ast -X std -c 'cc -D_BLD_DLL -D_BLD_ast' run "$iffe_test"
    name=$(echo "$iffe_test" | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/$name.h"
done

for iffe_test in ${iffe_sh_tests_2[@]}; do
    iffe -v -X ast -X std -c 'cc -D_BLD_DLL -D_BLD_ast' run $iffe_test
    name=$(echo "$iffe_test" | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/ast_$name.h"
done

for iffe_test in ${iffe_sh_tests_3[@]}; do
    iffe -v -X ast -X std -c 'cc -D_BLD_DLL -D_BLD_ast' run "$iffe_test"
    name=$(echo "$iffe_test" | cut -f1 -d.)
    cp "$base_dir/src/lib/libast/features/FEATURE/$iffe_test" "$base_dir/src/lib/libast/features/FEATURE/$name"
done

popd

pushd "$base_dir/"
cc -o "$bin_dir/lcgen" "$base_dir/src/lib/libast/port/lcgen.c"
"$bin_dir/lcgen" "$base_dir/src/lib/libast/include/lc.h" "$base_dir/src/lib/libast/port/lctab.c" < "$base_dir/src/lib/libast/port/lc.tab"
popd
