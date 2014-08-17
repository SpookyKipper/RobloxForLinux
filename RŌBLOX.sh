#RŌBLOXForLinux
#==============
#
#This is the RŌBLOX that can be ran by Wine. ALL CREDIT GIVEN TO Jonathan Alfonso <alfonsojon1997@gmail.com>
#
export RLWVERSION=2.0.2
export RLWCHANNEL=STABLE
export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox
export WINETRICKSDEV=/tmp/winetricks
export WINEARCH=win32
export WINEDLLOVERRIDES=winebrowser.exe,winemenubuilder.exe=

echo 'Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL

removeicons () {
	if [[ -e $HOME/Desktop/ROBLOX\ Player.desktop ]] || [[ -e $HOME/Desktop/ROBLOX\ Player.lnk ]]; then
		rm -rf $HOME/Desktop/ROBLOX\ Player.desktop
		rm -rf $HOME/Desktop/ROBLOX\ Player.lnk
	fi
	if [[ -e $HOME/Desktop/ROBLOX\ Studio*.desktop ]] || [[ -e $HOME/Desktop/ROBLOX\ Studio*.lnk ]]; then
		rm -rf $HOME/Desktop/ROBLOX\ Studio*.desktop
		rm -rf $HOME/Desktop/ROBLOX\ Studio*.lnk
	fi
	if [[ -e $HOME/.local/share/applications/wine/Programs/Roblox ]]; then
		rm -rf $HOME/.local/share/applications/wine/Programs/Roblox
	fi
}

spawndialog () {
	zenity \
		--window-icon=$RBXICON \
		--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL \
		--$1 \
		--no-wrap \
		--text="$2"
}

download () {
	wget $1 -O $2 2>&1 | \
	sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | \
	zenity \
		--progress \
		--window-icon=$RBXICON \
		--title='Downloading' \
		--auto-close \
		--no-cancel \
		--width=450 \
		--height=120
}

if [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
else
	download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
	export RBXICON=$HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
fi

depcheck () {
	if command -v zenity >/dev/null 2>&1; then
		echo 'zenity installed, continuing'
	else
		echo "Please install zenity via your system's package manager."
		exit 127
	fi
	if command -v shasum >/dev/null 2>&1; then
		echo 'shasum installed, continuing'
	else
		echo "Please install shasum via your system's package manager."
		spawndialog error "Please install shasum via your system's package manager"
		exit 127
	fi
	if command -v wget >/dev/null 2>&1; then
		echo 'wget installed, continuing'
	else
		echo "Please install wget via your system's package manager."
		spawndialog error "Please install wget via your system's package manager."
		exit 127
	fi
	if command -v wine >/dev/null 2>&1; then
		echo 'Wine installed, continuing'
	else
		echo 'Please install Wine from www.winehq.org/download'
		spawndialog error 'Please install Wine from www.winehq.org/download'
		xdg-open 'http://www.winehq.org/download'
		exit 127
	fi
	if [ ! -e $WINEPREFIX ]; then
		spawndialog info 'Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.'
		download http://roblox.com/install/setup.ashx /tmp/RobloxPlayerLauncher.exe
		download http://winetricks.googlecode.com/svn/trunk/src/winetricks /tmp/winetricks
		chmod +x /tmp/winetricks
		/tmp/winetricks -q vcrun2008 vcrun2012 winhttp wininet | zenity \
			--window-icon=$RBXICON \
			--title='Running winetricks' \
			--text='Running winetricks ...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
		wine /tmp/RobloxPlayerLauncher.exe | zenity \
			--window-icon=$RBXICON \
			--title='Installing Roblox' \
			--text='Installing Roblox ...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
		cd $WINEPREFIX
		ROBLOXPROXY=`find . -iname 'RobloxProxy.dll'| sed "s/.\/drive_c/C:/" | tr '/' '\\'`
		wine regsvr32 "$ROBLOXPROXY"
		download ftp://ftp.mozilla.org/pub/firefox/releases/31.0esr/win32/en-US/Firefox%20Setup%2031.0esr.exe /tmp/Firefox-Setup-31.0esr.exe
		wine /tmp/Firefox-Setup-31.0esr.exe /SD | zenity \
			--window-icon=$RBXICON \
			--title='Installing Mozilla Firefox' \
			--text='Installing Mozilla Firefox 31.0 ESR ...' \
			--progress \
			--pulsate \
			--no-cancel \
			--auto-close
		removeicons
	fi
}

playerwrapper () {
	if [[ $1 = legacy ]]; then
		export GAMEURL=`\
		zenity \
			--title='Roblox Linux Wrapper v'$RLWVERSION'-'$RLWCHANNEL \
			--window-icon=$RBXICON \
			--entry \
			--text='Paste the URL for the game here.' \
			--ok-label='Play' \
			--width=450 \
			--height=122`
			GAMEID=`echo $GAMEURL | cut -d "=" -f 2`
		if [[ -n "$GAMEID" ]]; then
			wine "`find $WINEPREFIX -name RobloxPlayerBeta.exe`" --id $GAMEID | \
			zenity \
				--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
				--title='ROBLOX' \
				--text='Starting ROBLOX Player...' \
				--progress \
				--pulsate \
				--auto-close \
				--no-cancel \
				--width=362 \
				--height=122
			removeicons
		else
			return
		fi
	else
		wine 'C:\Program Files\Mozilla Firefox\firefox.exe' http://www.roblox.com/Games.aspx
		removeicons
	fi
}

studiowrapper () {
	if [[ "`find $WINEPREFIX -name RobloxStudioBeta.exe`" = '' ]]; then
		wine "`find $WINEPREFIX -name RobloxStudioLauncherBeta.exe`" | zenity \
			--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
			--title='ROBLOX' \
			--text='Installing ROBLOX Studio ...' \
			--progress \
			--pulsate \
			--auto-close \
			--no-cancel \
			--width=362 \
			--height=122
		wineserver -k
		removeicons
	fi
	wine "`find $WINEPREFIX -name RobloxStudioBeta.exe`" | zenity \
		--window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
		--title='ROBLOX' \
		--text='Starting ROBLOX Studio ...' \
		--progress \
		--pulsate \
		--auto-close \
		--no-cancel \
		--width=362 \
		--height=122
	removeicons
}

main () {
	if [[ -d "$HOME/.rlw" ]]; then
		export RLW_INSTALL_OPT='Uninstall Roblox Linux Wrapper'
	else
		export RLW_INSTALL_OPT='Install Roblox Linux Wrapper (Recommended)'
	fi
	sel=`zenity \
		--title='ROBLOX Linux Wrapper' \
		--window-icon=$RBXICON \
		--width=480 \
		--height=238 \
		--cancel-label='Quit' \
		--list \
		--text 'Select a choice.' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Play Roblox' \
		FALSE 'Play Roblox (Legacy Mode)' \
		FALSE 'Roblox Studio' \
		FALSE "$RLW_INSTALL_OPT" \
		FALSE 'Reset Roblox to defaults' \
		FALSE 'Uninstall Roblox' `
	case $sel in
	'Play Roblox')
		playerwrapper; main;;
	'Play Roblox (Legacy Mode)')
		playerwrapper legacy; main;;
	'Roblox Studio')
		studiowrapper; main;;
	'Install Roblox Linux Wrapper (Recommended)')
		cat <<-EOF > $HOME/.local/share/applications/Roblox.desktop
		[Desktop Entry]
		Comment=Play Roblox
		Name=Roblox Linux Wrapper
		Exec=$HOME/.rlw/rlw-stub.sh
		Actions=RFAGroup;ROLWiki;
		GenericName=Building Game
		Icon=roblox
		Categories=Game;
		Type=Application

		[Desktop Action ROLWiki]
		Name='Roblox on Linux Wiki'
		Exec=xdg-open 'http://roblox.wikia.com/wiki/Roblox_On_Linux'

		[Desktop Action RFAGroup]
		Name='Roblox for All'
		Exec=xdg-open 'http://www.roblox.com/Groups/group.aspx?gid=292611'
		EOF
		mkdir $HOME/.rlw
		download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh $HOME/.rlw/rlw.sh
		download https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw-stub.sh $HOME/.rlw/rlw-stub.sh
		download http://img1.wikia.nocookie.net/__cb20130302012343/robloxhelp/images/f/fb/ROBLOX_Circle_Logo.png $HOME/.local/share/icons/roblox.png
		chmod +x $HOME/.rlw/rlw.sh
		chmod +x $HOME/.rlw/rlw-stub.sh
		chmod +x $HOME/.local/share/applications/Roblox.desktop
		xdg-desktop-menu install --novendor $HOME/.local/share/applications/Roblox.desktop
		xdg-desktop-menu forceupdate
		if [[ -f $HOME/.rlw/rlw-stub.sh && -f $HOME/.rlw/rlw.sh && -f $HOME/.local/share/icons/roblox.png && -f $HOME/.local/share/applications/Roblox.desktop ]]; then
			spawndialog info 'Roblox Linux Wrapper was installed successfully.'
		else
			spawndialog error 'Roblox Linux Wrapper did not install successfully.\nPlease ensure you are connected to the internet and try again.'
		fi
		main;;
	'Uninstall Roblox Linux Wrapper')
		xdg-desktop-menu uninstall $HOME/.local/share/applications/Roblox.desktop
		rm -rf $HOME/.rlw
		if [[ -e $HOME/.local/share/icons/roblox.png ]]; then
			rm -rf $HOME/.local/share/icons/roblox.png
		fi
		rm -rf $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png
		xdg-desktop-menu forceupdate
		if [[ -d $HOME/.rlw ]] || [[ -e $HOME/.local/share/icons/hicolor/512x512/apps/roblox.png ]]; then
			spawndialog error 'Roblox Linux Wrapper is still installed. Please try uninstalling again.'
		else
			spawndialog info 'Roblox Linux Wrapper has been uninstalled successfully.'
		fi
		main;;
	'Reset Roblox to defaults')
		rm -rf $WINEPREFIX;
		depcheck; main;;
	'Uninstall Roblox')
		if [[ -e $WINEPREFIX ]]; then
			wineserver -k; rm -rf $WINEPREFIX; removeicons; spawndialog info 'Roblox has been uninstalled successfully.'
		fi
		exit;;
	esac
}

# Run dependency check & launch main function
depcheck; main
