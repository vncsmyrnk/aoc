# list recipes available
default:
  @just --list

# downloads the input for a specified puzzle. The downloaded file will be placed on the puzzle's folder
fetch-input year day:
  @mkdir -p {{year}}/day{{day}}
  @curl -SL -o {{year}}/day{{day}}/input.txt "https://adventofcode.com/{{year}}/day/{{day}}/input" \
    --cookie "session=$AOC_SESSION_COOKIE"
