#! /bin/env bash
# Add a new exercise

# set -eux

ROOT_DIR=$PWD
EXERCISES="$PWD/exercises"
EXERCISE_PATCHES="$PWD/.patches"
CONSTANTS="$PWD/src/constants.py"

if [[ $(basename "$ROOT_DIR") != "starklings" ]]; then echo "Execute $0 at the root of the starklings project!"; exit; fi
if ([ -z "$1" ] || [ ! -f "$1" ]); then echo "Please provide a valid path to the exercise!"; exit; fi
if ([ -z "$2" ] || [ ! -f "$2" ]); then echo "Please provide a valid path to the exercise solution!"; exit; fi
if [ -z "$3" ]; then echo "Please provide a valid name for the exercise folder!"; exit; fi

EXERCISE=$1
EXERCISE_SOLUTION=$2
EXERCISE_FOLDER=$3

mkdir -p "$EXERCISES/$EXERCISE_FOLDER"
mkdir -p "$EXERCISE_PATCHES/$EXERCISE_FOLDER"

diff -Nb -U0 $EXERCISE $EXERCISE_SOLUTION > "$EXERCISE_PATCHES/$EXERCISE_FOLDER/$(basename $EXERCISE).patch"
cp $EXERCISE "$EXERCISES/$EXERCISE_FOLDER/$(basename $EXERCISE)"

echo "Done"
echo "Add or adapt '("exercises/$EXERCISE_FOLDER", ["$(basename $EXERCISE '.cairo')"]),' in $CONSTANTS"
