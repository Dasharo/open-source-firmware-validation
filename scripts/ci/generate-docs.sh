#!/usr/bin/env bash

set -x

gen_doc_lib() {
    local _in_file="$1"
    local _out_file="$(basename $_in_file)"
    _out_file="docs/lib/${_out_file%.*}.html"

    python3 -m robot.libdoc "$_in_file" "$_out_file" 
}

gen_doc_test() {
    local _in_file="$1"
    local _out_file="$(basename $_in_file)"
    _out_file="docs/test/${_out_file%.*}.html"

    python3 -m robot.testdoc "$_in_file" "$_out_file"
}

mkdir -p docs/test docs/lib

# Generate library documentation
gen_doc_lib keywords.robot
gen_doc_lib keys-and-keywords/flashrom.robot  
gen_doc_lib keys-and-keywords/heads-keywords.robot

for lib in lib/**.robot; do
    gen_doc_lib "$lib"
done

# Generate test suite documentation
for suite in dasharo-*/*.robot; do
    gen_doc_test "$suite"
done
