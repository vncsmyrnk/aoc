#!/bin/bash

function fails_if_input_does_not_exist() {
  if [ ! -f ./input.txt ]; then
    echo "input file required. Check project or AOC docs for more information about how to to get it"
    exit 1
  fi
}
