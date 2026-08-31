#!/bin/bash

## #ddev-generated

# Shared helpers for host-side xb commands.

resolve_canvas_dir() {
  ddev exec -- php -r '
$composer = json_decode((string) file_get_contents("composer.json"), true);
$paths = $composer["extra"]["installer-paths"] ?? [];
foreach ($paths as $path => $conditions) {
  if (in_array("type:drupal-module", $conditions, true)) {
    echo str_replace("{\$name}", "canvas", $path);
    exit(0);
  }
}
echo "modules/contrib/canvas";
'
}

init_canvas_paths() {
  local script_dir="$1"
  local docroot_prefix

  CANVAS_DIR_RELATIVE="$(resolve_canvas_dir)"
  CANVAS_DIR_ON_HOST="$script_dir/../../../$CANVAS_DIR_RELATIVE"
  CANVAS_DIR_INSIDE_CONTAINER="/var/www/html/$CANVAS_DIR_RELATIVE"
  CANVAS_UI_DIR_INSIDE_CONTAINER="$CANVAS_DIR_INSIDE_CONTAINER/ui"

  docroot_prefix="${CANVAS_DIR_RELATIVE%/modules/contrib/canvas}"
  if [ "$docroot_prefix" = "$CANVAS_DIR_RELATIVE" ]; then
    docroot_prefix=""
  fi
  SETTINGS_DDEV_PATH="${docroot_prefix:+$docroot_prefix/}sites/default/settings.ddev.php"
  CORE_DIR_IN_CONTAINER="/var/www/html/${docroot_prefix:+$docroot_prefix/}core"
}
