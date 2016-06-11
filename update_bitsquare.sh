#!/bin/sh

cd ~/bitsquare
git pull
mvn clean package -DskipTests
echo "Update done."
