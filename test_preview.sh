#!/bin/bash

# This will just create some temporary changes in this repo so you can test the script

printf "\nconsole.log('debug: hello world')\n" >> test/existing_file.js

git add test/existing_file.js

printf "\nconsole.log('debug: hello world here too')\n" >> test/existing_file.js
