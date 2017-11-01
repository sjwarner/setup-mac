#!/bin/bash
set -e

# macOS development setup
#
# Run this script to install and setup basic tools on a machine.
# Or run it to update current setup to latest changes.
# Steal the bits you like and adjust it to your needs.

# Become super user before starting work
sudo -v

printf "\nSetting up system with latest toys ...\n\n"

printf "\nUpdating macOS\n"
sudo softwareupdate -i -a

if [[ "$(xcode-select -p)" == "" ]]; then
  printf "\nInstalling Xcode\n"
  xcode-select --install
fi

# Brew
if ! command -v brew > /dev/null 2>&1; then
  printf "\nInstalling Brew\n"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

printf "\nInstalling Brew formulas\n"
brew update
brew upgrade

# Install new taps from ./brew.txt
comm -23 \
  <(sort brew.txt) \
  <( \
    { \
      brew ls --full-name; \
      brew cask ls | sed -e 's#^#Caskroom/cask/#'; \
    } \
    | sort \
  ) \
  | xargs brew install

# Remove old taps
comm -13 <(sort brew.txt) <(brew leaves | sort) \
  | xargs brew rm

# Remove old cask taps
comm -13 \
  <(sort brew.txt) \
  <(brew cask ls | sed -e 's#^#Caskroom/cask/#') \
  | xargs brew cask rm

brew cleanup

printf "\n\n\nAll good. Enjoy your day human."
