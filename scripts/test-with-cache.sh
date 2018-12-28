#! /bin/bash
# Activate virtual environment
. /appenv/bin/activate

pip download -d /build -r requirements_test.txt --no-input 
# -d is the destination flag


# Install appplication test requirements
echo 'pip install --no-index -f /build -r requirements_test.txt'
pip install --no-index -f /build -r requirements_test.txt
# --no-index: don't download dependencies
# -f  find dependencies in build folder


# Run test.sh arguments
exec $@
