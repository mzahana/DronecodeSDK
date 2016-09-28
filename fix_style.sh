#!/bin/bash

# This script runs astyle and complains about lines that are too long
# over all files ending in .h or .cpp listed by git in the given
# directory.

# Check for the latest astyle version
ASTYLE_VER_REQUIRED="Artistic Style Version 2.05.1"

ASTYLE_VER=`astyle --version`
if [ "$ASTYLE_VER" != "$ASTYLE_VER_REQUIRED" ];
then
    echo "Error: you're using ${ASTYLE_VER}"
    echo "but should be using ${ASTYLE_VER_REQUIRED} instead"
    exit 1
fi

# Check that exactly one directory is given
if [ $# -eq 0 ];
then
    echo "No directory supplied"
    echo "Usage: ./fix_style.sh dir"
    exit 1

elif [ $# -gt 1 ];
then
    echo "Too many directories supplied"
    echo "Usage: ./fix_style.sh dir"
    exit 1
fi

# Find the directory of this script because the file astylerc should be
# next to it.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Keep track of errors for the exit value
ERROR_FOUND=false

# Go through all .h and .cpp files listed by git
git ls-tree -r HEAD --name-only | grep -E "\.h$|\.cpp$" | while read LINE;
do
    # Run astyle with given astylerc
    astyle --options=$SCRIPT_DIR/astylerc $LINE

    # Check for lines too long
    GREP_RESULT=`grep  -n '.\{100\}' $LINE`

    if [[ $GREP_RESULT ]]; then
        echo "Line too long $LINE"
        echo "$GREP_RESULT"
        ERROR_FOUND=true
    fi
done

if $ERROR_FOUND ; then
    exit 1
fi