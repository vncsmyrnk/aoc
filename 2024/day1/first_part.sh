#!/bin/bash

# Solves the first part of day 1.
# Takes an input with 2 number columns, orders both individually,
# computes the absolute difference and sums it all up

if [ ! -f ./input.txt ]; then
  echo "input file required. Check project or AOC docs for more information about how to to get it"
  exit 1
fi

awk '{ print $1 }' input.txt | sort > /tmp/first-column.txt
awk '{ print $2 }' input.txt | sort > /tmp/second-column.txt
paste /tmp/first-column.txt /tmp/second-column.txt > /tmp/ordered.txt
awk '{ print $1 - $2 }' /tmp/ordered.txt > /tmp/ordered-diff.txt
ordered_sum_diff=$(awk -i ~/projects/aoc/utils/lib.awk '{ sum += abs($1) }; END { print sum }' /tmp/ordered-diff.txt)
echo "ordered diff sum is: $ordered_sum_diff"
