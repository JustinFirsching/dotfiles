#!/bin/sh

if [ -d "/opt/android-sdk" ]; then
    export ANDROID_HOME=/opt/android-sdk
    export PATH=$ANDROID_HOME/cmdline-tools:$PATH
    export PATH=$ANDROID_HOME/platform-tools:$PATH
fi
