#!/bin/bash

# Check the heaviest directories in the user's home directory

find ~ -maxdepth 1 -mindepth 1 | xargs -n 1 du -sh | egrep '[0-9]+[MG]' | sort -n