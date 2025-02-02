#!/bin/bash

# Solves the second part of day 1.
# Takes the same input, multiplies the first column elements by
# the amount of times they appear on the second column

source ${AOC_UTILS_PATH:-"../../utils"}/lib.sh

fails_if_input_does_not_exist

awk '{ print $1 }' input.txt > /tmp/first-column.txt
awk '{ print $2 }' input.txt > /tmp/second-column.txt
awk '{ print $1 }' input.txt | xargs -I {} grep -c {} /tmp/second-column.txt > /tmp/first-to-second-similarity-weight.txt
paste /tmp/first-column.txt /tmp/first-to-second-similarity-weight.txt > /tmp/first-column-similarity-weights.txt
awk '{ sum += $1 * $2 }; END { print sum }' /tmp/first-column-similarity-weights.txt
