# GitHub Actions Reset Guide

## Option 1: Clear All GitHub Actions Caches (Via GitHub UI)

1. Go to: https://github.com/Mijaelbrand/yoga-challenge-flutter
2. Click on "Actions" tab
3. Click on "Management" in the left sidebar (or go to Settings → Actions → General)
4. Find "Caches" section
5. Click "Delete all caches" or delete individual caches

## Option 2: Force Clean Build with New Workflow

Create a completely new workflow file that bypasses all caching:

```yaml
name: iOS Clean Build v2
on:
  workflow_dispatch:  # Manual trigger only
  push:
    branches: [ main ]

jobs:
  clean-build-ios:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
      with:
        clean: true
        fetch-depth: 0
        
    - name: Clean Everything
      run: |
        rm -rf ~/Library/Caches/
        rm -rf ~/.pub-cache/
        rm -rf ~/Library/Developer/Xcode/DerivedData/
        
    - name: Setup Flutter Fresh
      run: |
        git clone https://github.com/flutter/flutter.git --branch stable --depth 1
        export PATH="$PATH:$PWD/flutter/bin"
        flutter doctor
        
    - name: Build iOS
      run: |
        export PATH="$PATH:$PWD/flutter/bin"
        flutter clean
        flutter pub get
        flutter build ios --release --no-codesign
```

## Option 3: Create New Repository (Nuclear Option)

### Steps:
1. Create new repo: `yoga-challenge-flutter-v2`
2. Push current code to new repo
3. GitHub Actions will start fresh with no cache

### Commands:
```bash
# Add new remote
git remote add fresh https://github.com/Mijaelbrand/yoga-challenge-flutter-v2.git

# Push to new repo
git push fresh main

# Update origin to point to new repo
git remote set-url origin https://github.com/Mijaelbrand/yoga-challenge-flutter-v2.git
```

## Option 4: Reset Actions Without New Repo

### Delete and Recreate Workflows:
```bash
# Delete workflows folder
rm -rf .github/

# Recreate with new workflow
mkdir -p .github/workflows/
# Add new workflow file

# Commit with new workflow
git add .
git commit -m "Reset GitHub Actions with fresh workflows"
git push
```

## Option 5: Use Different Runner or Build Matrix

Change the runner OS or version to force fresh environment:

```yaml
runs-on: macos-13  # Instead of macos-latest
# or
runs-on: macos-12  # Different version
```

## Recommended Approach

1. **Try Option 1 first** - Clear all caches via GitHub UI
2. **Then Option 2** - Create new workflow with aggressive cleaning
3. **If still failing, Option 3** - New repository for completely fresh start

## Quick Test After Reset

After resetting, push a simple test commit to verify fresh build:

```bash
echo "# Build Reset Test $(date)" >> README.md
git add README.md
git commit -m "Test fresh build after reset"
git push
```

Check the Actions tab to confirm new build uses current code.