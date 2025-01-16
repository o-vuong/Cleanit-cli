#!/bin/bash

# Ensure Gum is installed
if ! command -v gum &>/dev/null; then
  gum style --foreground "#ff0000" "Gum is not installed. Install it first: https://github.com/charmbracelet/gum"
  exit 1
fi

# Function to check if a directory exists
check_directory() {
  if [ ! -d "$1" ]; then
    gum style --foreground "#ff0000" --border normal "Error: Directory does not exist: $1"
    exit 1
  fi
}

# Function to create a folder if it doesn't exist
create_folder() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
    gum style --foreground "#00e9ff" "Created folder: $folder"
  fi
}

# Function to clean path by removing double slashes
clean_path() {
  local path="$1"
  echo "$path" | sed 's#/\+#/#g'
}

# Function to format log message
format_log() {
  local action="$1"
  local source="$2"
  local target="$3"
  local color="$4"

  # Clean up paths
  local clean_source=$(clean_path "$source")
  local clean_target=$(clean_path "$target")

  # Format with consistent styling
  gum join \
    "$(gum style --foreground "$color" "$action: $(basename "$clean_source")")" \
    "$(gum style --foreground "#00e9ff" "→")" \
    "$(gum style --foreground "#00e9ff" "$clean_target")"
}

# Function to navigate directories
navigate_directory() {
  local current_dir="$1"
  while true; do
    selected_dir=$(find "$current_dir" -maxdepth 1 -type d | gum choose --no-limit --placeholder "Select a directory to navigate or press Enter to select current directory")
    if [ -z "$selected_dir" ]; then
      echo "$current_dir"
      break
    else
      current_dir="$selected_dir"
    fi
  done
}

# Prompt for directory
directory=$(navigate_directory "$PWD")
check_directory "$directory"

# Confirm dry-run mode
dry_run=$(gum confirm "Enable dry-run mode (simulate without changes)?" && echo true || echo false)

# Ignore dotfiles
ignore_dotfiles=$(gum confirm "Ignore dotfiles (files starting with '.')?" && echo true || echo false)

# Read loose files
loose_files=()
while IFS= read -r -d $'\0' file; do
  loose_files+=("$file")
done < <(find "$directory" -maxdepth 1 -type f -print0)

total_files=${#loose_files[@]}
if [ $total_files -eq 0 ]; then
  gum style --foreground "#ff0000" --border normal "No loose files found in the directory!"
  exit 0
fi

# Initialize log entries array
log_entries=()

# Start organizing
gum style --foreground "#00e9ff" "Organizing files by extension..."
echo

# Process files
for file in "${loose_files[@]}"; do
  if [ "$ignore_dotfiles" = true ] && [[ "$(basename "$file")" == .* ]]; then
    continue
  fi

  ext="${file##*.}"
  if [ -z "$ext" ] || [ "$ext" = "$(basename "$file")" ]; then
    ext="others"
  fi
  folder="$directory/$ext"

  # Create the folder if it doesn't exist and move file
  if [ "$dry_run" = false ]; then
    create_folder "$folder"
    mv "$file" "$folder/$(basename "$file")"
    log_entries+=("$(format_log "Moved" "$file" "$folder" "#00ff00")")
  else
    log_entries+=("$(format_log "Dry-run" "$file" "$folder" "#ffff00")")
  fi
done

# Display logs in a styled box
if [ ${#log_entries[@]} -gt 0 ]; then
  # Print header
  gum style --border normal --align center --foreground "#00e9ff" "File Organization Summary"
  echo
  # Print entries
  gum style --border normal --padding "1 2" --margin "1" --align left --bold \
    "$(printf "  %s\n" "${log_entries[@]}")"
else
  gum style --border normal \
    --padding "1 2" \
    --margin "1" \
    "No files were moved."
fi

# Completion message
gum style --foreground "#00e9ff" --border normal "File organization complete!"
