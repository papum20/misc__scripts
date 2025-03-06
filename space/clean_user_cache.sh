#!/bin/bash

# Remove some of the user's files, mostly cache

rm -rf ~/.gradle/caches/ \
	.cache/vscode-cpptools \
	.cache/pip \
	.cache/mesa_shader_cache \
	.cache/JetBrains \
	.cache/google-chrome \
	.cache/coursier

# Remove cache of old, uninstalled Android Studio versions 
# rm -rf .cache/Google/AndroidStudio<VERSION>

# Check unused VMs in ~/VirtualBox VMs/ and ~/.vagrant.d/boxes/