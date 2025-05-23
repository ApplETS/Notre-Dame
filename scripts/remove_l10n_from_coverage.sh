#!/bin/bash

# Directory to search
DIRECTORY="./lib/l10n"

# Loop through all .dart files in the directory
for file in "$DIRECTORY"/*.dart; do
  # Skip if file doesn't exist (in case of no matches)
  [ -e "$file" ] || continue

  # Read the first line of the file
  first_line=$(head -n 1 "$file")

  # Check if the first line is already the coverage comment
  if [[ "$first_line" != "// coverage:ignore-file" ]]; then
    echo "Modifying: $file"
    # Insert the comment at the top of the file
    { echo "// coverage:ignore-file"; cat "$file"; } > "$file.tmp" && mv "$file.tmp" "$file"
  fi
done
