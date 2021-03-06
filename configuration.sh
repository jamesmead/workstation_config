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
        # General UI/UX
        ###############################################################################

        echo ""
        echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          echo "What would you like it to be?"
          read COMPUTER_NAME
          sudo scutil --set ComputerName $COMPUTER_NAME
          sudo scutil --set HostName $COMPUTER_NAME
          sudo scutil --set LocalHostName $COMPUTER_NAME
          sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
        fi

        echo ""
        echo "Expanding the save panel by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

        echo ""
        echo "Automatically quit printer app once the print jobs complete"
        defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

        echo ""
        echo "Disable Photos.app from starting everytime a device is plugged in"
        defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

        echo ""
        echo "Enable Dark Mode and Finder Accent Colour"
        defaults write "Apple Global Domain" AppleInterfaceStyle -string "Dark"
        defaults write "Apple Global Domain" AppleAccentColor -integer 5
        defaults write "Apple Global Domain" AppleAquaColorVariant -bool true
        defaults write "Apple Global Domain" AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"

        echo ""
        echo "Disable recently used apps from Dock"
        defaults write com.apple.dock show-recents -bool false

        ###############################################################################
        # General Power and Performance modifications
        ###############################################################################

        ################################################################################
        # Trackpad, mouse, keyboard, Bluetooth accessories, and input
        ###############################################################################

        echo ""
        echo "Enable tap to click?"
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

        echo ""
        echo "Disable Natural Scroll Direction?"
        defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
        defaults write com.apple.swipescrolldirection -bool false

        echo ""
        echo "Setting trackpad & mouse speed to a reasonable number"
        defaults write -g com.apple.trackpad.scaling 1
        defaults write -g com.apple.mouse.scaling 1.5

        ###############################################################################
        # Screen
        ###############################################################################

        echo ""
        echo "Where do you want screenshots to be stored? Please enter a folder name or hit ENTER if you want ~/Desktop as default"
        # Thanks https://github.com/omgmog
        read screenshot_location
        echo ""
        if [ -z "${screenshot_location}" ]
        then
          # If nothing specified, we default to ~/Desktop
          screenshot_location="${HOME}/Desktop"
        else
          # Otherwise we use input
          if [[ "${screenshot_location:0:1}" != "/" ]]
          then
            # If input doesn't start with /, assume it's relative to home
            screenshot_location="${HOME}/${screenshot_location}"
          fi
        fi
        echo "Setting location to ${screenshot_location}"
        defaults write com.apple.screencapture location -string "${screenshot_location}"

        echo ""
        echo "What format should screenshots be saved as? (hit ENTER for PNG, options: BMP, GIF, JPG, PDF, TIFF) "
        read screenshot_format
        if [ -z "$1" ]
        then
          echo ""
          echo "Setting screenshot format to PNG"
          defaults write com.apple.screencapture type -string "png"
        else
          echo ""
          echo "Setting screenshot format to $screenshot_format"
          defaults write com.apple.screencapture type -string "$screenshot_format"
        fi

        ###############################################################################
        # Finder
        ###############################################################################

        echo ""
        echo "Show icons for hard drives, servers, and removable media on the desktop"
        defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

        echo ""
        echo "Show hidden files in Finder by default"
        defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder

        echo ""
        echo "Show all filename extensions in Finder by default"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        echo ""
        echo "Disable icons on Desktop"
        defaults write com.apple.finder CreateDesktop -bool false && killall Finder

        echo ""
        echo "Disable the warning when changing a file extension"
        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

        echo ""
        echo "Use column view in all Finder windows by default"
        defaults write com.apple.finder FXPreferredViewStyle Clmv

        echo ""
        echo "Avoid creation of .DS_Store files on network volumes"
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

        ###############################################################################
        # Dock & Mission Control
        ###############################################################################

        echo ""
        echo "Wipe all (default) app icons from the Dock"
        echo "(This is only really useful when setting up a new Mac, or if you don't use the Dock to launch apps.)"
        defaults write com.apple.dock persistent-apps -array

        echo ""
        echo "Setting the icon size of Dock items to 33 pixels for optimal size/screen-realestate"
        defaults write com.apple.dock tilesize -int 33

        # echo ""
        # echo "Set Dock to auto-hide and remove the auto-hiding delay"
        # read -r response
        # if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        #   defaults write com.apple.dock autohide -bool true
        #   defaults write com.apple.dock autohide-delay -float 0
        #   defaults write com.apple.dock autohide-time-modifier -float 0
        # fi

        echo ""
        echo "Set Dock orientation to the right"
        defaults write com.apple.dock orientation -string "right"

        ###############################################################################
        # Chrome, Safari, & WebKit
        ###############################################################################

        echo ""
        echo "Privacy: Don't send search queries to Apple"
        defaults write com.apple.Safari UniversalSearchEnabled -bool false
        defaults write com.apple.Safari SuppressSearchSuggestions -bool true

        echo ""
        echo "Hiding Safari's bookmarks bar by default"
        defaults write com.apple.Safari ShowFavoritesBar -bool false

        echo ""
        echo "Hiding Safari's sidebar in Top Sites"
        defaults write com.apple.Safari ShowSidebarInTopSites -bool false

        echo ""
        echo "Disabling Safari's thumbnail cache for History and Top Sites"
        defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

        echo ""
        echo "Enabling Safari's debug menu"
        defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

        echo ""
        echo "Making Safari's search banners default to Contains instead of Starts With"
        defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

        echo ""
        echo "Removing useless icons from Safari's bookmarks bar"
        defaults write com.apple.Safari ProxiesInBookmarksBar "()"

        echo ""
        echo "Enabling the Develop menu and the Web Inspector in Safari"
        defaults write com.apple.Safari IncludeDevelopMenu -bool true
        defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
        defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

        echo ""
        echo "Adding a context menu item for showing the Web Inspector in web views"
        defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

        ###############################################################################
        # Messages                                                                    #
        ###############################################################################

        echo ""
        echo "Disable automatic emoji substitution in Messages.app? (i.e. use plain text smileys)"
        read -r response
        defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

        echo ""
        echo "Disable smart quotes in Messages.app? (it's annoying for messages that contain code)"
        defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

        echo ""
        echo "Disable continuous spell checking in Messages.app?"
        defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

        ###############################################################################
        # Package Managers
        ###############################################################################

        echo ""
        echo "Install brew? (y/n)"
        read -r response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
          /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
          brew tap homebrew/cask
          brew update -y # update brew
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
          "Terminal" "Transmission"; do
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


