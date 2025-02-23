#!/bin/bash

# Directory where applications are typically installed on macOS
APPS_DIR="/Applications"

# Initialize arrays for results
INSTALLED_VIA_BREW=()
ALREADY_INSTALLED_VIA_BREW=()
UNABLE_TO_INSTALL=()

# Arrays to hold packages scheduled for installation and their corresponding original app names
CASK_PACKAGES=()
CASK_APPS=()
FORMULA_PACKAGES=()
FORMULA_APPS=()

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew is not installed. Please install it before continuing."
  exit 1
fi

# Function to normalize app names: convert to lowercase and replace spaces with hyphens
normalize_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g'
}

# Precompute the list of installed Homebrew packages (casks and formulas)
installed_casks=$(brew list --cask --versions | awk '{print $1}')
installed_formulas=$(brew list --versions | awk '{print $1}')

# Function to check if a package is already installed via Homebrew
is_installed_via_brew() {
  local pkg="$1"
  if echo "$installed_casks" | grep -Fxq "$pkg" || echo "$installed_formulas" | grep -Fxq "$pkg"; then
    return 0
  else
    return 1
  fi
}

# Build a list of application names from /Applications using find
app_list=()
while IFS= read -r -d '' app; do
  app_name=$(basename "$app" .app)
  app_list+=("$app_name")
done < <(find "$APPS_DIR" -maxdepth 1 -type d -name "*.app" -print0)

# Process each application: check if available via Homebrew and not already installed
for app in "${app_list[@]}"; do
  brew_name=$(normalize_name "$app")
  if is_installed_via_brew "$brew_name"; then
    echo "Application '$app' is already installed via Homebrew."
    ALREADY_INSTALLED_VIA_BREW+=("$app")
  else
    if brew info --cask "$brew_name" &> /dev/null; then
      CASK_PACKAGES+=("$brew_name")
      CASK_APPS+=("$app")
      echo "Scheduled '$app' (brew package: $brew_name) for cask installation."
    elif brew info "$brew_name" &> /dev/null; then
      FORMULA_PACKAGES+=("$brew_name")
      FORMULA_APPS+=("$app")
      echo "Scheduled '$app' (brew package: $brew_name) for formula installation."
    else
      echo "Application '$app' is not available via Homebrew."
      UNABLE_TO_INSTALL+=("$app")
    fi
  fi
done

# Delete any existing apps for cask installations BEFORE installing via brew
if [ ${#CASK_APPS[@]} -gt 0 ]; then
  echo -e "\nDeleting existing applications for cask installations..."
  APPS_PATHS=()
  for app in "${CASK_APPS[@]}"; do
    app_path="$APPS_DIR/$app.app"
    if [ -d "$app_path" ]; then
      APPS_PATHS+=("$app_path")
    fi
  done
  if [ ${#APPS_PATHS[@]} -gt 0 ]; then
    echo "Deleting: ${APPS_PATHS[@]}"
    sudo rm -rf "${APPS_PATHS[@]}"
  fi
fi

# Install all cask packages at once (verbose output for debugging)
if [ ${#CASK_PACKAGES[@]} -gt 0 ]; then
  echo -e "\nInstalling casks: ${CASK_PACKAGES[@]}"
  brew install --cask "${CASK_PACKAGES[@]}"
  if [ $? -eq 0 ]; then
    INSTALLED_VIA_BREW+=("${CASK_PACKAGES[@]}")
  else
    echo "Error installing one or more casks."
  fi
fi

# Install all formula packages at once (verbose output for debugging)
if [ ${#FORMULA_PACKAGES[@]} -gt 0 ]; then
  echo -e "\nInstalling formulas: ${FORMULA_PACKAGES[@]}"
  brew install "${FORMULA_PACKAGES[@]}"
  if [ $? -eq 0 ]; then
    INSTALLED_VIA_BREW+=("${FORMULA_PACKAGES[@]}")
  else
    echo "Error installing one or more formulas."
  fi
fi

# Summary of operations
echo -e "\nSummary of Operations:"
if [ ${#ALREADY_INSTALLED_VIA_BREW[@]} -gt 0 ]; then
  echo "Applications already installed via Homebrew:"
  printf "%s\n" "${ALREADY_INSTALLED_VIA_BREW[@]}"
fi

if [ ${#INSTALLED_VIA_BREW[@]} -gt 0 ]; then
  echo "Applications installed via Homebrew:"
  printf "%s\n" "${INSTALLED_VIA_BREW[@]}"
fi

if [ ${#UNABLE_TO_INSTALL[@]} -gt 0 ]; then
  echo "Applications that failed to install via Homebrew:"
  printf "%s\n" "${UNABLE_TO_INSTALL[@]}"
fi
