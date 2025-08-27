#!/bin/bash

echo "=== Fresh Repository Setup Script ==="
echo ""
echo "This script helps you push to a new repository for a completely fresh start"
echo ""

# Option 1: Add as new remote
echo "Option 1: Add new repository as additional remote"
echo "----------------------------------------"
echo "Run these commands:"
echo ""
echo "git remote add fresh https://github.com/Mijaelbrand/yoga-challenge-flutter-fresh.git"
echo "git push fresh main"
echo ""

# Option 2: Replace origin
echo "Option 2: Replace origin with new repository"
echo "----------------------------------------"
echo "Run these commands:"
echo ""
echo "git remote rename origin old-origin"
echo "git remote add origin https://github.com/Mijaelbrand/yoga-challenge-flutter-fresh.git"
echo "git push -u origin main"
echo ""

# Option 3: Clone and push fresh
echo "Option 3: Fresh clone and push (cleanest)"
echo "----------------------------------------"
echo "Run these commands in a new folder:"
echo ""
echo "git clone https://github.com/Mijaelbrand/yoga-challenge-flutter.git temp-clone"
echo "cd temp-clone"
echo "git remote set-url origin https://github.com/Mijaelbrand/yoga-challenge-flutter-fresh.git"
echo "git push -u origin main"
echo ""

echo "=== After creating new repo ==="
echo "1. Go to GitHub and create 'yoga-challenge-flutter-fresh' repository"
echo "2. Don't initialize it with README or .gitignore"
echo "3. Run one of the options above"
echo "4. GitHub Actions will start fresh with no cache!"