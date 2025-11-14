#!/bin/bash

# Check if EDITOR is set
if [ -z "$EDITOR" ]; then
  echo "Error: EDITOR environment variable is not set."
  echo "Please set EDITOR in your shell profile (e.g., export EDITOR=nvim)"
  exit 1
fi

# Get today's date
today=$(date +"%Y-%m-%d")
daily_file="Desktop/DAILY--${today}.md"

# Build list of existing markdown files with priority ordering
file_list=$(
  {
    # Priority 0: Today's DAILY (always first, even if doesn't exist yet)
    echo "$daily_file"

    # Priority 1: Other Desktop files
    find "$HOME/Desktop" -maxdepth 1 -name "*.md" -type f 2>/dev/null | while read -r f; do
      basename_f=$(basename "$f")
      # Skip if it's today's DAILY (already added)
      [[ "$basename_f" != "DAILY--${today}.md" ]] && echo "Desktop/$basename_f"
    done

    # Priority 2: Documents/TODO.md
    [ -f "$HOME/Documents/TODO.md" ] && echo "Documents/TODO.md"

    # Priority 3: PROJECTS
    find "$HOME/Documents/PROJECTS" -name "*.md" -type f 2>/dev/null | sed "s|$HOME/Documents/||"

    # Priority 4: AREAS
    find "$HOME/Documents/AREAS" -name "*.md" -type f 2>/dev/null | sed "s|$HOME/Documents/||"

    # Priority 5: RESOURCES
    find "$HOME/Documents/RESOURCES" -name "*.md" -type f 2>/dev/null | sed "s|$HOME/Documents/||"

    # Priority 6: JOURNALS
    find "$HOME/Documents/JOURNALS" -name "*.md" -type f 2>/dev/null | sed "s|$HOME/Documents/||"

    # Priority 7: ARCHIVES
    find "$HOME/Documents/ARCHIVES" -name "*.md" -type f 2>/dev/null | sed "s|$HOME/Documents/||"
  }
)

# Helper function to convert display path to actual path
path_to_actual() {
  local display_path="$1"
  if [[ "$display_path" == Desktop/* ]]; then
    echo "$HOME/Desktop/$(echo "$display_path" | sed 's|Desktop/||')"
  else
    echo "$HOME/Documents/$display_path"
  fi
}

# Prompt for file selection or custom title using fzf with preview
selection=$(echo "$file_list" | fzf \
  --prompt="Select existing or type new title: " \
  --height=40% \
  --reverse \
  --print-query \
  --preview-window='right:60%:wrap' \
  --preview="sh -c 'case {} in Desktop/*) preview_path=\"$HOME/Desktop/\$(echo {} | sed \"s|Desktop/||\")\";; *) preview_path=\"$HOME/Documents/{}\";; esac; if [ -f \"\$preview_path\" ]; then glow -w 80 \"\$preview_path\" 2>/dev/null || cat \"\$preview_path\"; else echo \"[New file - will be created]\"; fi'" \
  | tail -n1)

# Exit if user cancelled (Escape or Ctrl-C)
if [ $? -ne 0 ] || [ -z "$selection" ]; then
  exit 0
fi

# Check if selection is an existing file or a new title
if echo "$file_list" | grep -Fxq "$selection"; then
  # Existing file selected - convert display path to actual path
  note_file=$(path_to_actual "$selection")

  # Create DAILY file if selected but doesn't exist yet
  if [[ "$selection" == "$daily_file" ]] && [ ! -f "$note_file" ]; then
    cat >"$note_file" <<EOF
# Daily Note - ${today}

EOF
  fi
else
  # New title entered - create new note on Desktop
  slug=$(echo "$selection" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
  note_file="$HOME/Desktop/NOTE--${slug}--${today}.md"
  header="# ${selection} - ${today}"

  # Create file with header if it doesn't exist
  if [ ! -f "$note_file" ]; then
    cat >"$note_file" <<EOF
${header}

EOF
  fi
fi

# Open in editor
"$EDITOR" "$note_file"
