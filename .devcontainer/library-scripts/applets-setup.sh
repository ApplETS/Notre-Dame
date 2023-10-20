#/bin/bash


# setup flutter
cd /flutter
git checkout 3.3.10
# Prepares flutter dependencies 
flutter precache
cd /workspaces/Notre-Dame
flutter pub get

# This requires user input to accept the licenses but can't be run on java 11 so we run it before switch
flutter doctor --android-licenses


# set java version
update-java-alternatives -s java-1.11.0-openjdk-amd64