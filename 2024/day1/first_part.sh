#!/bin/bash

# Solves the first part of day 1.
# Takes an input with 2 number columns, orders both individually,
# computes the absolute difference and sums it all up

set -e

source ${AOC_UTILS_PATH:-"../../utils"}/lib.sh

fails_if_input_does_not_exist

awk '{ print $1 }' input.txt | sort > /tmp/first-column.txt
awk '{ print $2 }' input.txt | sort > /tmp/second-column.txt
paste /tmp/first-column.txt /tmp/second-column.txt > /tmp/ordered.txt
awk '{ print $1 - $2 }' /tmp/ordered.txt > /tmp/ordered-diff.txt
awk -i ~/projects/aoc/utils/lib.awk '{ sum += abs($1) }; END { print sum }' /tmp/ordered-diff.txt
