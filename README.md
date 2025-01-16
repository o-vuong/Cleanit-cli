# Cleanit CLI

A smart command-line tool that automatically organizes files in a directory by their extensions. Built with shell script and enhanced with [Gum](https://github.com/charmbracelet/gum) for a beautiful terminal user interface.

## Features

- 🗂️ Automatically organizes files by their extensions
- 🔍 Dry-run mode to preview changes before applying them
- 🎨 Beautiful terminal UI with interactive prompts
- ⚙️ Configurable options for ignoring dotfiles
- 📝 Detailed operation logs with color-coded status
- 💫 Creates folders automatically as needed

## Prerequisites

- Bash shell
- [Gum](https://github.com/charmbracelet/gum) - For the interactive terminal UI

## Installation

1. Install Gum following the instructions at: https://github.com/charmbracelet/gum
2. Download the cleanit.sh script
3. Make it executable:
   ```bash
   chmod +x cleanit.sh
   ```

## Usage

Run the script:
```bash
./cleanit.sh
```

The script will guide you through the following steps:

1. Enter the directory to organize (defaults to current directory)
2. Choose whether to enable dry-run mode
3. Choose whether to ignore dotfiles
4. View the organization summary

## Options

- **Directory Selection**: Specify which directory to organize
- **Dry Run Mode**: Preview changes without actually moving files
- **Ignore Dotfiles**: Option to skip files that start with a dot (.)

## How It Works

1. The script first checks for loose files in the specified directory
2. For each file:
   - Extracts the file extension
   - Creates a folder named after the extension (if it doesn't exist)
   - Moves the file into the corresponding folder
3. Files without extensions are moved to an "others" folder
4. Provides a detailed summary of all operations

## Example Output

The script provides a beautiful color-coded summary of all operations:
- 🟢 Green: Successfully moved files
- 🟡 Yellow: Dry-run simulated moves
- 🔵 Blue: Created folders
- 🔴 Red: Errors (if any)

## License

MIT License

## Contributing

Feel free to submit issues and enhancement requests!