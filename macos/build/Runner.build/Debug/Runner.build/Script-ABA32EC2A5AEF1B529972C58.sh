#!/bin/sh
if ! diff "${PODS_PODFILE_DIR_PATH}/Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null 2>&1 ; then
  echo "warning: Pods out of sync – copying Podfile.lock → Manifest.lock" >&2
  cp "${PODS_PODFILE_DIR_PATH}/Podfile.lock" "${PODS_ROOT}/Manifest.lock"
fi
echo "SUCCESS" > "${SCRIPT_OUTPUT_FILE_0}"

