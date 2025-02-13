#!/bin/bash

echo 'Cleaning previously created files in parent module'
rm -f ./DEPENDENCIES

echo 'Running dash tool for all dependencies license compliance'
chmod +x $PWD/eclipse-dash/dash.jar $PWD/VehicleConnect/Podfile.deps

java -jar $PWD/eclipse-dash/dash.jar $PWD/VehicleConnect/Podfile.deps -summary $PWD/DEPENDENCIES
chmod +x $PWD/DEPENDENCIES
echo "DEPENDENCIES file created."

echo 'Checking for failed dependencies'
if  grep -q "restricted" "$PWD/DEPENDENCIES"; then
    echo "Failed dependencies found. Exiting with status 1."
    exit 1
else
    echo "All dependencies are compliant."
fi
