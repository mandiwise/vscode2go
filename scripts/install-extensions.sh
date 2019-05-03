#!/bin/bash

vscode_extensions_dir=$1
extensions_file=$2

# Check if extensions file doesn't exist have anything in it
if [ ! -s $extensions_file ]; then
  echo "The extensions file does not exist or is empty"
else
  # Remove lines only containing whitespace, then try to install each extensions
  sed '/^[ \t]*$/d' $extensions_file | while read -r ext || [ -n "$ext" ]; do
    url=https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${ext%.*}/vsextensions/${ext##*.}/latest/vspackage
    
    # Check if the extension URL exists, and install it if it does
    if curl --retry 5 --output /dev/null --silent --fail -r 0-0 "$url"; then
      mkdir -p ${vscode_extensions_dir}/${ext} \
        && curl -JLs --retry 5 ${url} | bsdtar --strip-components=1 -xf - -C ${vscode_extensions_dir}/${ext} extension \
        && echo "✅  Installed ${ext}"
    else
      echo "⛔️  Extension URL does not exist: $url"
    fi
  done
fi
