#!/bin/sh

if [ -d "/opt/android-sdk" ]; then
    export ANDROID_HOME=/opt/android-sdk
    path_prepend "$ANDROID_HOME/platform-tools"
    path_prepend "$ANDROID_HOME/cmdline-tools"
fi
