#!/bin/sh

###
# SOME COMMANDS WILL NOT WORK ON macOS (Sierra or newer)
# For Sierra or newer, see https://github.com/mathiasbynens/dotfiles/blob/master/.macos
###

# Alot of these configs have been taken from the various places
# on the web, most from here
# https://github.com/mathiasbynens/dotfiles/blob/5b3c8418ed42d93af2e647dc9d122f25cc034871/.osx
# https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos

# Set the colours you can use
black='\033[0;30m'
white='\033[0;37m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# Set continue to false by default
CONTINUE=false

echo ""
cecho "###############################################" $red
cecho "#        DO NOT RUN THIS SCRIPT BLINDLY       #" $red
cecho "#         YOU'LL PROBABLY REGRET IT...        #" $red
cecho "#                                             #" $red
cecho "#              READ IT THOROUGHLY             #" $red
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" $red
cecho "###############################################" $red
echo ""


echo ""
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
fi

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  cecho "Please go read the script, it only takes a few minutes" $red
  exit
fi

case "$(uname -s)" in

    Darwin)
        echo 'Mac OS X'

        # Here we go.. ask for the administrator password upfront and run a
        # keep-alive to update existing `sudo` time stamp until script has finished
        sudo -v
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


        ###############################################################################
        # Software Installs
        ###############################################################################

        echo ""
        echo "Install Spectacle? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          curl https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip -o /tmp/Spectacle.zip
          unzip -a /tmp/Spectacle.zip -d /Applications
          rm /tmp/Spectacle.zip
        fi

        echo ""
        echo "Install Aerial Screensaver? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install aerial
        fi

        echo ""
        echo "Install Slack? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install slack
        fi

        echo ""
        echo "Install iTerm2? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install iterm2
        fi

        echo ""
        echo "Install Zsh? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew install zsh zsh-completions
          chsh -s /bin/zsh # sets default SHELL
	        echo "fpath=(/usr/local/share/zsh-completions $fpath)" >> ~/.zshrc
	        rm -f ~/.zcompdump; compinit
	      fi

        echo ""
        echo "Install Oh my ZSH? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

          # adds avit theme
          sed -i '' -e "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"avit\"/g" ~/.zshrc
          
          # adds zsh plugins
          git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
          git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
          # update plugins
          newPlugins=()
          newPlugins+=("${plugins[@]}" "zsh-syntax-highlighting" "zsh-autosuggestions")
          sed -i '' -e "s/plugins=(${plugins})/plugins=(${newPlugins})/g" ~/.zshrc
          source ~/.zshrc
        fi

        cho ""
        echo "Install Custom Fonts? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew tap homebrew/cask-fonts
          brew cask install font-fira-code
        fi

        echo ""
        echo "Install VS Code? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install visual-studio-code
        fi

        echo ""
        echo "Install Docker? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install docker
        fi

        echo ""
        echo "Install Spotify? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew cask install spotify spotify-notifications
        fi

        echo ""
        echo "Install Kubectl? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          brew install kubectl
          # update plugins
          newPlugins=()
          newPlugins+=("${plugins[@]}" "kubectl")
          sed -i '' -e "s/plugins=(${plugins})/plugins=(${newPlugins})/g" ~/.zshrc
          source ~/.zshrc
        fi

        ###############################################################################
        # Kill affected applications
        ###############################################################################

        echo ""
        cecho "Done!" $cyan
        echo ""
        echo ""
        cecho "################################################################################" $white
        echo ""
        echo ""
        cecho "Note that some of these changes require a logout/restart to take effect." $red
        cecho "Killing some open applications in order to take effect." $red
        echo ""

        find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
        for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
          "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
          "Terminal" "Transmission" "iTerm2"; do
          killall "${app}" > /dev/null 2>&1
        done

        ;;
    Linux)
        echo 'Linux'
        ;;
    CYGWIN*|MINGW32*|MSYS*)
        echo 'MS Windows'
        ;;

        # Add here more strings to compare
        # See correspondence table at the bottom of this answer

    *)
        echo 'other OS' 
        ;;
esac


