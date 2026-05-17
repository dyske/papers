#!/bin/bash
cd "$(dirname "$0")"
git push
status=$?
# self-delete on success
if [ $status -eq 0 ]; then
  rm -- "$0"
fi
echo
echo "(Press any key to close this window.)"
read -n 1 -s
exit $status
