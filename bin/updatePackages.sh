#!/usr/bin/env bash
set -euo pipefail

README="README.md"
PACKAGES_DIR="packages"
BUILD_SCRIPT="bin/build.sh"

if [ ! -f "$README" ]; then
  echo "README.md not found"
  exit 1
fi

if [ ! -d "$PACKAGES_DIR" ]; then
  echo "packages/ directory not found"
  exit 1
fi

mkdir -p "$(dirname "$BUILD_SCRIPT")"

to_pascal_case() {
  echo "$1" | awk -F '[-_ ]+' '{
    out=""
    for (i=1; i<=NF; i++) {
      if ($i != "") {
        part=tolower($i)
        out = out toupper(substr(part,1,1)) substr(part,2)
      }
    }
    print out
  }'
}

to_camel_case() {
  echo "$1" | awk -F '[-_ ]+' '{
    out=""
    for (i=1; i<=NF; i++) {
      if ($i != "") {
        part=tolower($i)
        if (i == 1) {
          out = out part
        } else {
          out = out toupper(substr(part,1,1)) substr(part,2)
        }
      }
    }
    print out
  }'
}

TMP_README="$(mktemp)"
TMP_SECTION="$(mktemp)"
TMP_BUILD="$(mktemp)"
TMP_PACKAGES="$(mktemp)"

# Collect package info sorted by folder name
for dir in "$PACKAGES_DIR"/*; do
  [ -d "$dir" ] || continue
  basename "$dir"
done | sort > "$TMP_PACKAGES"

# ----------------------------
# Build README Packages section
# ----------------------------
{
  echo "## Packages"
  echo
  echo "| Package | Path | Docs |"
  echo "| ------- | :--: | :---: |"

  while IFS= read -r folder_name; do
    [ -z "$folder_name" ] && continue

    package_name="$(to_pascal_case "$folder_name")"
    package_path="$(to_camel_case "$folder_name")"

    echo "| $package_name | \`packages/$package_path\` | [Docs](https://sapling.itsabitrandom.com/api/$package_name) |"
  done < "$TMP_PACKAGES"
} > "$TMP_SECTION"

# Replace the ## Packages section in README.md
awk -v section_file="$TMP_SECTION" '
BEGIN {
  in_packages = 0
  replaced = 0
}

/^## Packages$/ {
  while ((getline line < section_file) > 0) print line
  close(section_file)
  in_packages = 1
  replaced = 1
  next
}

/^## / && in_packages {
  in_packages = 0
}

!in_packages {
  print
}

END {
  if (!replaced) {
    print ""
    while ((getline line < section_file) > 0) print line
    close(section_file)
  }
}
' "$README" > "$TMP_README"

mv "$TMP_README" "$README"

# ----------------------------
# Build bin/build.sh
# ----------------------------
{
  echo "#!/usr/bin/env bash"
  echo "set -euo pipefail"
  echo
  echo "rm -rf build"
  echo "mkdir build"
  echo

  while IFS= read -r folder_name; do
    [ -z "$folder_name" ] && continue

    package_path="$(to_camel_case "$folder_name")"

    echo "rojo build packages/$package_path -o build/$package_path.rbxm"
  done < "$TMP_PACKAGES"
} > "$TMP_BUILD"

mv "$TMP_BUILD" "$BUILD_SCRIPT"
chmod +x "$BUILD_SCRIPT"

rm -f "$TMP_SECTION" "$TMP_PACKAGES"

echo "Updated README.md and $BUILD_SCRIPT"