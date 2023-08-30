#!/usr/bin/env sh
#

KNOWN_PROFILES=("Light" "Dark")

if [ $# -eq 0 ]; then
    echo "No argument provided. Please provide a profile."
    exit 1
fi

profile=$1

if ! [[ " ${KNOWN_PROFILES[@]} " =~ " ${profile} " ]]; then
    echo "Invalid profile. Please choose from: ${KNOWN_PROFILES[*]}"
    exit 1
fi

osascript <<EOF
  tell application "iTerm"
		tell current window
		  set profile to (first profile whose name is "$profile")
		end tell
  end tell
EOF

echo "Profile: $profile"
