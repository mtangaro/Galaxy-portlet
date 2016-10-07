#!/bin/bash

mkdir -p lib
wget http://central.maven.org/maven2/com/google/code/gson/gson/2.6.2/gson-2.6.2.jar -P lib/

blade gw clean jar
