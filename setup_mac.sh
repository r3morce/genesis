#!/usr/bin/env bash

# Setup script for setting up a new macos machine

echo "Starting setup"

# install xcode CLI
xcode-select —-install

# Check for Homebrew to be present, install if it's missing
if test ! $(which brew); then
    echo "Installing homebrew…"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    
    echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
    export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
fi

# Update homebrew recipes
brew update

PACKAGES=(
    1password
    alfred
    bartycrouch
    bettertouchtool
    brave-browser 
    cocoapods
    discord
    fastlane
    gitkraken
    imagemagick
    iterm2
    karabiner-elements 
    mactracker
    meetingbar
    microsoft-teams
    numi
    overkill
    python@3.9
    rbenv
    ruby
    ruby@2.7
    sentry-cli
    signal
    skitch
    slack
    spotify
    swiftgen
    swiftlint
    visual-studio-code
    zeplin
    zsh-autosuggestions
)

echo "Installing packages…"
brew install ${PACKAGES[@]}

# any additional steps

# om my zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# link readline
brew link --force readline

echo "Cleaning up…"
brew cleanup

echo ""
echo "  _          _    _                _     _  _       "
echo " | |__      | |_ | |_  __ __      | |__ | || | ___  "
echo " | / /      |  _||   \ \ \ /      |  _ \ \_. |/ -_) "
echo " |_\_\       \__||_||_|/_\_\      |____/ |__/ \___| "
echo ""
