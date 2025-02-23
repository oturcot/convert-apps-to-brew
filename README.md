# Convert macOS Applications to Homebrew Installations

This script examines your applications located in the `/Applications` directory, checks if corresponding Homebrew packages (cask or formula) exist, and, if so, removes the locally installed copy and installs it via Homebrew. This allows you to manage more of your applications using Homebrew, simplifying updates and maintenance.

---

## Table of Contents

- [How It Works](#how-it-works)
  - [App Discovery](#app-discovery)
  - [Homebrew Check](#homebrew-check)
  - [Uninstall & Install](#uninstall--install)
  - [Grouped Operations](#grouped-operations)

- [Why Use It](#why-use-it)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Example Output](#example-output)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## How It Works

### App Discovery

- The script searches for all `.app` directories in `/Applications`.
- For each app, it normalizes the application name by converting it to lowercase and replacing spaces with hyphens (e.g., `Visual Studio Code` → `visual-studio-code`).

### Homebrew Check

- If an app matches a Homebrew package (either via `brew info --cask` or `brew info`), it will be scheduled for installation.
- If the app is already installed via Homebrew, it’s skipped.
- If no matching Homebrew package is found, the app is marked as “unable to install via Homebrew.”

### Uninstall & Install

- For any application found to have a matching cask, the script removes the existing `.app` from `/Applications` using `sudo` to bypass permission issues.
- It then installs that application via `brew install --cask`.
- For formula-based packages, the same logic applies but uses `brew install` without the `--cask` flag.

### Grouped Operations

- Cask packages are installed in a single grouped operation.
- Formula packages are installed together in another grouped operation.
- All deletions happen in one `sudo rm -rf` command before the installations begin, minimizing multiple password prompts.

---

## Why Use It

- **Centralized Management**: Manage all (or most) of your applications and tools via Homebrew, simplifying updates (`brew upgrade`) and maintenance.
- **Consistency**: Leverage Homebrew’s version control, rollback features, and easy install/uninstall procedures.
- **Automation**: Easily replicate the same set of apps on new machines using a single script or Brewfile.

---

## Prerequisites

- [Homebrew](https://brew.sh/) must be installed on your Mac.
- You need sufficient permissions to run `sudo rm -rf` on `/Applications` (especially for apps installed from the Mac App Store).

---

## Installation

1. **Clone or Download** this repository:
   ```bash
   git clone https://github.com/oturcot/convert-apps-to-brew.git
   cd convert-apps-to-brew
   ```

2. **Make the Script Executable**:
   ```bash
   chmod +x convert-apps-to-brew.sh
   ```

---

## Usage

1. **Run the Script**:
   ```bash
   ./convert-apps-to-brew.sh
   ```
   - You may be prompted for your password once if the script needs elevated permissions to remove any App Store–installed apps or other restricted applications.

2. **What Happens Next**:
   - The script displays which apps are scheduled for conversion, which are already installed via Homebrew, and which cannot be installed via Homebrew.
   - It removes the scheduled apps from `/Applications` (using `sudo`) and installs them using brew.

3. **Review the Summary**:
   - At the end, you’ll see a summary of which apps were successfully installed via Homebrew, which were already installed, and which could not be installed.

---

## Example Output

```
Scheduled 'Visual Studio Code' (brew package: visual-studio-code) for cask installation.
Application 'Steam Link' is not available via Homebrew.
Application 'Docker' is already installed via Homebrew.

Deleting existing applications for cask installations...
Deleting: /Applications/Visual Studio Code.app

Installing casks: visual-studio-code
==> Downloading ...
==> Installing Cask visual-studio-code
...
==> Success!

Summary of Operations:
Applications already installed via Homebrew:
Docker

Applications installed via Homebrew:
visual-studio-code

Applications that failed to install via Homebrew:
Steam Link
```

---

## Troubleshooting

- **Permission Denied**: If you see permission issues, ensure your user is an administrator and that `sudo` is configured properly.
- **Name Mismatches**: Some apps have different naming conventions on Homebrew. If an application can’t be found, you may need to manually rename it or install a different cask/formula name.
- **Already Installed Errors**: If the installation fails due to “App already exists,” the script might not have been able to delete the existing `.app`. Try running with administrator privileges, or manually remove the offending `.app` and re-run.

---

## License

This project is released under the [MIT License](LICENSE).
