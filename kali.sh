#!/bin/bash
#-METADATA---------------------------------------------------------------#
#  Filename: kali.sh                                (Update: 05/12/2017) #
#-INFO-------------------------------------------------------------------#
#  Post-installation script for Kali Linux                               #
#                                                                        #
#-AUTHOR(S)--------------------------------------------------------------#
#  Creator   : g0tmilk ~ https://blog.g0tmi1k.com/                       #
#  Forked by : drkpasngr ~ https://drkpasngr.github.io/                  #
#  Forked by : anasfullstack ~ https://github.com/AnasFullStack          #
#                                                                        #
#-TARGET OPERATING SYSTEM------------------------------------------------#
#  Designed for: Kali Linux Rolling [x64] (VM - Virtualbox)              #
#  Tested on   : N/A                                                     #
#                                                                        #
#-LICENSE----------------------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT                      #
#                                                                        #
#-INSTRUCTIONS-----------------------------------------------------------#
#  1. Run as root after a clean install of Kali Linux.                   #
#     *  Create a clone or snapshot prior to any changes.                #
#                             ---                                        #
#  2. You will need 25GB+ free HDD space before running.                 #
#                             ---                                        #
#  3. Command line arguments:                                            #
#      -burp     = Automates configuring Burp Suite                      #
#      -dns      = Use OpenDNS and locks permissions                     #
#      -osx      = Changes to Apple keyboard layout                      #
#                                                                        #
#    -keyboard <value> = Change the keyboard layout language             #
#    -timezone <value> = Change the timezone location                    #
#                             ---                                        #
#  E.g. # bash kali.sh -burp -keyboard us -dns                           #
#                                                                        #
#-DISCLAIMER-------------------------------------------------------------#
#  ** This script configures Kali for _ME_. **                           #
#  ** EDIT it to meet _YOUR_ requirements! **                            #
#------------------------------------------------------------------------#


if [ 1 -eq 0 ]; then    # This is never true, thus it acts as block comments ;)
##########################################################################################
### One liner - Grab the latest version and execute! #####################################
##########################################################################################
wget -qO kali.sh https://raw.githubusercontent.com/AnasFullStack/kali-script/master/kali.sh \
  && bash kali.sh -burp -timezone "America/Toronto"
##########################################################################################
fi


#-Defaults-------------------------------------------------------------#


##### Location information
keyboardApple=false          # Using a Apple/Macintosh keyboard (non VM)?                [ --osx ]
keyboardLayout="us"         # Set keyboard layout                                       [ --keyboard us]
timezone="America/Toronto" # Set timezone location                                     [ --timezone US/Chicago ]

##### Optional steps
burpFree=true              # Disable configuring Burp Suite (for Burp Pro users...)     [ --burp ]
hardenDNS=false             # Set static & lock DNS name server                         [ --dns ]

##### (Optional) Enable debug mode?
#set -x

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                         # Where are we up to
TOTAL=$( grep '(${STAGE}/${TOTAL})' $0 | wc -l );(( TOTAL-- ))  # How many things have we got todo


#-Arguments------------------------------------------------------------#


##### Read command line arguments
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]; do
  opt="${1}";
  shift;
  case "$(echo ${opt} | tr '[:upper:]' '[:lower:]')" in
    -|-- ) break 2;;

    -osx|--osx )
      keyboardApple=true;;
    -apple|--apple )
      keyboardApple=true;;

    -dns|--dns )
      hardenDNS=true;;

    -burp|--burp )
      burpFree=true;;

    -keyboard|--keyboard )
      keyboardLayout="${1}"; shift;;
    -keyboard=*|--keyboard=* )
      keyboardLayout="${opt#*=}";;

    -timezone|--timezone )
      timezone="${1}"; shift;;
    -timezone=*|--timezone=* )
      timezone="${opt#*=}";;

    *) echo -e ' '${RED}'[!]'${RESET}" Unknown option: ${RED}${x}${RESET}" 1>&2 \
      && exit 1;;
   esac
done


##### Check user inputs
if [[ -n "${timezone}" && ! -f "/usr/share/zoneinfo/${timezone}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" Looks like the ${RED}timezone '${timezone}'${RESET} is incorrect/not supported (Example: ${BOLD}Europe/London${RESET})" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
  exit 1
elif [[ -n "${keyboardLayout}" && -e /usr/share/X11/xkb/rules/xorg.lst ]]; then
  if ! $(grep -q " ${keyboardLayout} " /usr/share/X11/xkb/rules/xorg.lst); then
    echo -e ' '${RED}'[!]'${RESET}" Looks like the ${RED}keyboard layout '${keyboardLayout}'${RESET} is incorrect/not supported (Example: ${BOLD}gb${RESET})" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
    exit 1
  fi
fi


#-Start----------------------------------------------------------------#


##### Check if we are running as root - else this script will fail (Hard!)
if [[ "${EUID}" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" This script must be ${RED}run as root${RESET}" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
  exit 1
else
  echo -e " ${BLUE}[*]${RESET} ${BOLD}Post-installation script for Kali Linux.${RESET}"
  sleep 3s
fi

if [ "${burpFree}" != "true" ]; then
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping Burp Suite${RESET} (missing: '$0 ${BOLD}--burp${RESET}')..." 1>&2
  sleep 2s
fi


##### Fix display output for GUI programs (when connecting via SSH)
export DISPLAY=:0.0
export TERM=xterm


##### Are we using GNOME?
if [[ $(which gnome-shell) ]]; then
  ##### Disable its auto notification package updater
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling GNOME's ${GREEN}notification package updater${RESET} service ~ in case it runs during this script"
  export DISPLAY=:0.0
  timeout 5 killall -w /usr/lib/apt/methods/http >/dev/null 2>&1


  ##### Disable screensaver
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling ${GREEN}screensaver${RESET}"
  xset s 0 0
  xset s off
  gsettings set org.gnome.desktop.session idle-delay 0
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping disabling package updater${RESET}..."
fi


##### Check Internet access
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Checking ${GREEN}Internet access${RESET}"
#--- Can we ping google?
for i in {1..10}; do ping -c 1 -W ${i} www.google.com &>/dev/null && break; done
#--- Run this, if we can't
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${RED}Possible DNS issues${RESET}(?)" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Will try and use ${YELLOW}DHCP${RESET} to 'fix' the issue" 1>&2
  chattr -i /etc/resolv.conf 2>/dev/null
  dhclient -r
  #--- Second interface causing issues?
  ip addr show eth1 &>/dev/null
  [[ "$?" == 0 ]] \
    && route delete default gw 192.168.155.1 2>/dev/null
  #--- Request a new IP
  dhclient
  dhclient eth0 2>/dev/null
  dhclient wlan0 2>/dev/null
  #--- Wait and see what happens
  sleep 15s
  _TMP="true"
  _CMD="$(ping -c 1 8.8.8.8 &>/dev/null)"
  if [[ "$?" -ne 0 && "$_TMP" == "true" ]]; then
    _TMP="false"
    echo -e ' '${RED}'[!]'${RESET}" ${RED}No Internet access${RESET}" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" You will need to manually fix the issue, before re-running this script" 1>&2
  fi
  _CMD="$(ping -c 1 www.google.com &>/dev/null)"
  if [[ "$?" -ne 0 && "$_TMP" == "true" ]]; then
    _TMP="false"
    echo -e ' '${RED}'[!]'${RESET}" ${RED}Possible DNS issues${RESET}(?)" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" You will need to manually fix the issue, before re-running this script" 1>&2
  fi
  if [[ "$_TMP" == "false" ]]; then
    (dmidecode | grep -iq virtual) && echo -e " ${YELLOW}[i]${RESET} VM Detected"
    (dmidecode | grep -iq virtual) && echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Try switching network adapter mode${RESET} (e.g. NAT/Bridged)"
    echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
    exit 1
  fi
else
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Detected Internet access${RESET}" 1>&2
fi

#--- GitHub under DDoS?
(( STAGE++ )); echo -e " ${GREEN}[i]${RESET} (${STAGE}/${TOTAL}) Checking ${GREEN}GitHub status${RESET}"
timeout 300 curl --progress -k -L -f "https://status.github.com/api/status.json" | grep -q "good" \
  || (echo -e ' '${RED}'[!]'${RESET}" ${RED}GitHub is currently having issues${RESET}. ${BOLD}Lots may fail${RESET}. See: https://status.github.com/" 1>&2 \
    && exit 1)


##### Enable default network repositories ~ http://docs.kali.org/general-use/kali-linux-sources-list-repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Enabling default OS ${GREEN}network repositories${RESET}"
#--- Add network repositories
file=/etc/apt/sources.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#--- Main
grep -q '^deb .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "\n\n# Kali Rolling\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Source
grep -q '^deb-src .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Disable CD repositories
sed -i '/kali/ s/^\( \|\t\|\)deb cdrom/#deb cdrom/g' "${file}"
#--- incase we were interrupted
dpkg --configure -a
#--- Update
apt -qq update
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue accessing network repositories${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are the remote network repositories ${YELLOW}currently being sync'd${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} Here is ${BOLD}YOUR${RESET} local network ${BOLD}repository${RESET} information (Geo-IP based):\n"
  curl -sI http://http.kali.org/README
  exit 1
fi


##### Check to see if Kali is in a VM. If so, install "Virtual Machine Addons/Tools" for a "better" virtual experiment
if (dmidecode | grep -iq vmware); then
  ##### Install virtual machines tools ~ http://docs.kali.org/general-use/install-vmware-tools-kali-guest
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VMware's (open) virtual machine tools${RESET}"
  apt -y -qq install open-vm-tools-desktop fuse \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
  apt -y -qq install make \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2    # There's a nags afterwards
  ## Shared folders support for Open-VM-Tools (some odd bug)
  file=/usr/local/sbin/mount-shared-folders; [ -e "${file}" ] && cp -n $file{,.bkup}
  cat <<EOF > "${file}" \
    || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

vmware-hgfsclient | while read folder; do
  echo "[i] Mounting \${folder}   (/mnt/hgfs/\${folder})"
  mkdir -p "/mnt/hgfs/\${folder}"
  umount -f "/mnt/hgfs/\${folder}" 2>/dev/null
  vmhgfs-fuse -o allow_other -o auto_unmount ".host:/\${folder}" "/mnt/hgfs/\${folder}"
done

sleep 2s
EOF
  chmod +x "${file}"
  ln -sf "${file}" /root/Desktop/mount-shared-folders.sh
elif (dmidecode | grep -iq virtualbox); then
  ##### Installing VirtualBox Guest Additions.   Note: Need VirtualBox 4.2.xx+ for the host (http://docs.kali.org/general-use/kali-linux-virtual-box-guest)
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VirtualBox's guest additions${RESET}"
  apt -y -qq install virtualbox-guest-x11 \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi


##### Set static & protecting DNS name servers.   Note: May cause issues with forced values (e.g. captive portals etc)
if [[ "${hardenDNS}" != "false" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting static & protecting ${GREEN}DNS name servers${RESET}"
  file=/etc/resolv.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
  chattr -i "${file}" 2>/dev/null
  #--- Use OpenDNS DNS
  #echo -e 'nameserver 208.67.222.222\nnameserver 208.67.220.220' > "${file}"
  #--- Use Google DNS
  echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > "${file}"
  #--- Protect it
  chattr +i "${file}" 2>/dev/null
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping DNS${RESET} (missing: '$0 ${BOLD}--dns${RESET}')..." 1>&2
fi


##### Update location information - set either value to "" to skip.
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET}"
#--- Configure keyboard layout (Apple)
if [ "${keyboardApple}" != "false" ]; then
  ( (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Applying ${GREEN}Apple hardware${RESET} profile" )
  file=/etc/default/keyboard; #[ -e "${file}" ] && cp -n $file{,.bkup}
  sed -i 's/XKBVARIANT=".*"/XKBVARIANT="mac"/' "${file}"
fi
#--- Configure keyboard layout (location)
if [[ -n "${keyboardLayout}" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET} ~ keyboard layout (${BOLD}${keyboardLayout}${RESET})"
  geoip_keyboard=$(curl -s http://ifconfig.io/country_code | tr '[:upper:]' '[:lower:]')
  [ "${geoip_keyboard}" != "${keyboardLayout}" ] \
    && echo -e " ${YELLOW}[i]${RESET} Keyboard layout (${BOLD}${keyboardLayout}${RESET}) doesn't match what's been detected via GeoIP (${BOLD}${geoip_keyboard}${RESET})"
  file=/etc/default/keyboard; #[ -e "${file}" ] && cp -n $file{,.bkup}
  sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="'${keyboardLayout}'"/' "${file}"
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping keyboard layout${RESET} (missing: '$0 ${BOLD}--keyboard <value>${RESET}')..." 1>&2
fi
#--- Changing time zone
if [[ -n "${timezone}" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET} ~ time zone (${BOLD}${timezone}${RESET})"
  echo "${timezone}" > /etc/timezone
  ln -sf "/usr/share/zoneinfo/$(cat /etc/timezone)" /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping time zone${RESET} (missing: '$0 ${BOLD}--timezone <value>${RESET}')..." 1>&2
fi
#--- Installing ntp tools
(( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ntpdate${RESET} ~ keeping the time in sync"
apt -y -qq install ntp ntpdate \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Update time
ntpdate -b -s -u pool.ntp.org
#--- Start service
systemctl restart ntp
#--- Remove from start up
systemctl disable ntp 2>/dev/null
#--- Only used for stats at the end
start_time=$(date +%s)


##### Update OS from network repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Updating OS${RESET} from network repositories"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Internet connection & Kali version/age"
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done         # Clean up      clean remove autoremove autoclean
export DEBIAN_FRONTEND=noninteractive
apt -qq update && APT_LISTCHANGES_FRONTEND=none apt -o Dpkg::Options::="--force-confnew" -y dist-upgrade --fix-missing 2>&1 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Cleaning up temp stuff
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done         # Clean up - clean remove autoremove autoclean
#--- Check kernel stuff
_TMP=$(dpkg -l | grep linux-image- | grep -vc meta)
if [[ "${_TMP}" -gt 1 ]]; then
  echo -e "\n ${YELLOW}[i]${RESET} Detected ${YELLOW}multiple kernels${RESET}"
  TMP=$(dpkg -l | grep linux-image | grep -v meta | sort -t '.' -k 2 -g | tail -n 1 | grep "$(uname -r)")
  if [[ -z "${TMP}" ]]; then
    echo -e '\n '${RED}'[!]'${RESET}' You are '${RED}'not using the latest kernel'${RESET} 1>&2
    echo -e " ${YELLOW}[i]${RESET} You have it ${YELLOW}downloaded${RESET} & installed, just ${YELLOW}not USING IT${RESET}"
    #echo -e "\n ${YELLOW}[i]${RESET} You ${YELLOW}NEED to REBOOT${RESET}, before re-running this script"
    #exit 1
    sleep 30s
  else
    echo -e " ${YELLOW}[i]${RESET} ${YELLOW}You're using the latest kernel${RESET} (Good to continue)"
  fi
fi


##### Install kernel headers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kernel headers${RESET}"
apt -y -qq install make gcc "linux-headers-$(uname -r)" \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
if [[ $? -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue installing kernel headers${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are you ${YELLOW}USING${RESET} the ${YELLOW}latest kernel${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Reboot${RESET} your machine"
  #exit 1
  sleep 30s
fi


##### Install "kali full" meta packages (default tool selection)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kali-linux-full${RESET} meta-package"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Kali version (e.g. ARM, light, mini or docker...)"
#--- Kali's default tools ~ https://www.kali.org/news/kali-linux-metapackages/
apt -y -qq install kali-linux-full \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Set audio level
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting ${GREEN}audio${RESET} levels"
systemctl --user enable pulseaudio
systemctl --user start pulseaudio
pactl set-sink-mute 0 0
pactl set-sink-volume 0 25%


if [[ $(which gnome-shell) ]]; then
  ##### Configure GNOME 3
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}GNOME 3${RESET} ~ desktop environment"
  export DISPLAY=:0.0
  #-- Gnome Extension - Dash Dock (the toolbar with all the icons)
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true      # Set dock to use the full height
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'   # Set dock to the right
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false         # Set dock to be always visible
  gsettings set org.gnome.shell favorite-apps \
    "['gnome-terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox-esr.desktop', 'kali-burpsuite.desktop', 'gedit.desktop', 'gnome-screenshot.desktop']"
  #-- Gnome Extension - Alternate-tab (So it doesn't group the same windows up)
  GNOME_EXTENSIONS=$(gsettings get org.gnome.shell enabled-extensions | sed 's_^.\(.*\).$_\1_')
  echo "${GNOME_EXTENSIONS}" | grep -q "alternate-tab@gnome-shell-extensions.gcampax.github.com" \
    || gsettings set org.gnome.shell enabled-extensions "[${GNOME_EXTENSIONS}, 'alternate-tab@gnome-shell-extensions.gcampax.github.com']"
  #-- Gnome Extension - Drive Menu (Show USB devices in tray)
  GNOME_EXTENSIONS=$(gsettings get org.gnome.shell enabled-extensions | sed 's_^.\(.*\).$_\1_')
  echo "${GNOME_EXTENSIONS}" | grep -q "drive-menu@gnome-shell-extensions.gcampax.github.com" \
    || gsettings set org.gnome.shell enabled-extensions "[${GNOME_EXTENSIONS}, 'drive-menu@gnome-shell-extensions.gcampax.github.com']"
  #--- Workspaces
  gsettings set org.gnome.shell.overrides dynamic-workspaces true                          # Static
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 1                          # Increase workspaces count to 3
  #--- Top bar
  gsettings set org.gnome.desktop.interface clock-show-date true                           # Show date next to time in the top tool bar
  gsettings set org.gnome.desktop.interface clock-show-seconds true                        # Show seconds next to time in the top tool bar

  #--- Keyboard short-cuts
  (dmidecode | grep -iq virtual) && gsettings set org.gnome.mutter overlay-key "Alt_R"   # Change 'super' key to right side (rather than left key), if in a VM
  #--- Hide desktop icon
  dconf write /org/gnome/nautilus/desktop/computer-icon-visible true
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping GNOME${RESET}..." 1>&2
fi



##### Configure file   Note: need to restart xserver for effect
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}file${RESET} (Nautilus/Thunar) ~ GUI file system navigation"
#--- Settings
mkdir -p ~/.config/gtk-2.0/
file=~/.config/gtk-2.0/gtkfilechooser.ini; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/^.*ShowHidden.*/ShowHidden=false/' "${file}" 2>/dev/null \
  || cat <<EOF > "${file}"
[Filechooser Settings]
LocationMode=path-bar
ShowHidden=false
ExpandFolders=true
ShowSizeColumn=true
GeometryX=66
GeometryY=39
GeometryWidth=780
GeometryHeight=618
SortColumn=name
SortOrder=ascending
EOF
dconf write /org/gnome/nautilus/preferences/show-hidden-files false
#--- Bookmarks
file=/root/.gtk-bookmarks; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
mkdir -p /X
grep -q '^file:///X ' "${file}" 2>/dev/null \
  || echo 'file:///X X' >> "${file}"
grep -q '^file:///opt ' "${file}" 2>/dev/null \
  || echo 'file:///opt Tools' >> "${file}"
grep -q '^file:///usr/share ' "${file}" 2>/dev/null \
  || echo 'file:///usr/share Kali Tools' >> "${file}"
grep -q '^file:///var/www/html ' "${file}" 2>/dev/null \
  || echo 'file:///var/www/html www' >> "${file}"
  (dmidecode | grep -iq vmware) \
  && (mkdir -p /mnt/hgfs/ 2>/dev/null; grep -q '^file:///mnt/hgfs ' "${file}" 2>/dev/null \
    || echo 'file:///mnt/hgfs VMShare' >> "${file}")
grep -q '^file:///tmp ' "${file}" 2>/dev/null \
  || echo 'file:///tmp /tmp' >> "${file}"

#--- Configure file browser - Thunar (need to re-login for effect)
mkdir -p ~/.config/Thunar/
file=~/.config/Thunar/thunarrc; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/LastShowHidden=.*/LastShowHidden=TRUE/' "${file}" 2>/dev/null \
  || echo -e "[Configuration]\nLastShowHidden=FALSE" > "${file}"


##### Configure GNOME terminal   Note: need to restart xserver for effect
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring GNOME ${GREEN}terminal${RESET} ~ CLI interface"
gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited true
gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/background_type transparent
gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/background_darkness 0.85611499999999996


##### Configure bash - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}bash${RESET} ~ CLI shell"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
grep -q "cdspell" "${file}" \
  || echo "shopt -sq cdspell" >> "${file}"             # Spell check 'cd' commands
grep -q "autocd" "${file}" \
 || echo "shopt -s autocd" >> "${file}"                # So you don't have to 'cd' before a folder
grep -q "checkwinsize" "${file}" \
 || echo "shopt -sq checkwinsize" >> "${file}"         # Wrap lines correctly after resizing
grep -q "nocaseglob" "${file}" \
 || echo "shopt -sq nocaseglob" >> "${file}"           # Case insensitive pathname expansion
grep -q "HISTSIZE" "${file}" \
 || echo "HISTSIZE=" >> "${file}"                 # Bash history (memory scroll back)
grep -q "HISTFILESIZE" "${file}" \
 || echo "HISTFILESIZE=" >> "${file}"             # Bash history (file .bash_history)
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install bash colour - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bash colour${RESET} ~ colours shell output"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
grep -q '^force_color_prompt' "${file}" 2>/dev/null \
  || echo 'force_color_prompt=yes' >> "${file}"
sed -i 's#PS1='"'"'.*'"'"'#PS1='"'"'${debian_chroot:+($debian_chroot)}\\[\\033\[01;31m\\]\\u@\\h\\\[\\033\[00m\\]:\\[\\033\[01;34m\\]\\w\\[\\033\[00m\\]\\$ '"'"'#' "${file}"
grep -q "^export LS_OPTIONS='--color=auto'" "${file}" 2>/dev/null \
  || echo "export LS_OPTIONS='--color=auto'" >> "${file}"
grep -q '^eval "$(dircolors)"' "${file}" 2>/dev/null \
  || echo 'eval "$(dircolors)"' >> "${file}"
grep -q "^alias ls='ls $LS_OPTIONS'" "${file}" 2>/dev/null \
  || echo "alias ls='ls $LS_OPTIONS'" >> "${file}"
grep -q "^alias ll='ls $LS_OPTIONS -l'" "${file}" 2>/dev/null \
  || echo "alias ll='ls $LS_OPTIONS -l'" >> "${file}"
grep -q "^alias l='ls $LS_OPTIONS -lA'" "${file}" 2>/dev/null \
  || echo "alias l='ls $LS_OPTIONS -lA'" >> "${file}"
#--- All other users that are made afterwards
file=/etc/skel/.bashrc   #; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install grc
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}grc${RESET} ~ colours shell output"
apt -y -qq install grc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup aliases
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## grc diff alias' "${file}" 2>/dev/null \
  || echo -e "## grc diff alias\nalias diff='$(which grc) $(which diff)'\n" >> "${file}"
grep -q '^## grc dig alias' "${file}" 2>/dev/null \
  || echo -e "## grc dig alias\nalias dig='$(which grc) $(which dig)'\n" >> "${file}"
grep -q '^## grc gcc alias' "${file}" 2>/dev/null \
  || echo -e "## grc gcc alias\nalias gcc='$(which grc) $(which gcc)'\n" >> "${file}"
grep -q '^## grc ifconfig alias' "${file}" 2>/dev/null \
  || echo -e "## grc ifconfig alias\nalias ifconfig='$(which grc) $(which ifconfig)'\n" >> "${file}"
grep -q '^## grc mount alias' "${file}" 2>/dev/null \
  || echo -e "## grc mount alias\nalias mount='$(which grc) $(which mount)'\n" >> "${file}"
grep -q '^## grc netstat alias' "${file}" 2>/dev/null \
  || echo -e "## grc netstat alias\nalias netstat='$(which grc) $(which netstat)'\n" >> "${file}"
grep -q '^## grc ping alias' "${file}" 2>/dev/null \
  || echo -e "## grc ping alias\nalias ping='$(which grc) $(which ping)'\n" >> "${file}"
grep -q '^## grc ps alias' "${file}" 2>/dev/null \
  || echo -e "## grc ps alias\nalias ps='$(which grc) $(which ps)'\n" >> "${file}"
grep -q '^## grc tail alias' "${file}" 2>/dev/null \
  || echo -e "## grc tail alias\nalias tail='$(which grc) $(which tail)'\n" >> "${file}"
grep -q '^## grc traceroute alias' "${file}" 2>/dev/null \
  || echo -e "## grc traceroute alias\nalias traceroute='$(which grc) $(which traceroute)'\n" >> "${file}"
grep -q '^## grc wdiff alias' "${file}" 2>/dev/null \
  || echo -e "## grc wdiff alias\nalias wdiff='$(which grc) $(which wdiff)'\n" >> "${file}"
#configure  #esperanto  #ldap  #e  #cvs  #log  #mtr  #ls  #irclog  #mount2  #mount
#--- Apply new aliases
source "${file}" || source ~/.zshrc


##### Install bash completion - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bash completion${RESET} ~ tab complete CLI commands"
apt -y -qq install bash-completion \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
sed -i '/# enable bash completion in/,+7{/enable bash completion/!s/^#//}' "${file}"
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Configure aliases - root user
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}aliases${RESET} ~ CLI shortcuts"
#--- Enable defaults - root user
for FILE in /etc/bash.bashrc ~/.bashrc ~/.bash_aliases; do    #/etc/profile /etc/bashrc /etc/bash_aliases /etc/bash.bash_aliases
  [[ ! -f "${FILE}" ]] \
    && continue
  cp -n $FILE{,.bkup}
  sed -i 's/#alias/alias/g' "${FILE}"
done

##### Install git - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}git${RESET} ~ revision control"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Set as default editor
git config --global core.editor "vim"
#--- Set as default mergetool
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false
#--- Set as default push
git config --global push.default simple

##### Install metasploit ~ http://docs.kali.org/general-use/starting-metasploit-framework-in-kali
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}metasploit${RESET} ~ exploit framework"
apt -y -qq install metasploit-framework \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p ~/.msf4/modules/{auxiliary,exploits,payloads,post}/
#--- Fix any port issues
file=$(find /etc/postgresql/*/main/ -maxdepth 1 -type f -name postgresql.conf -print -quit);
[ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/port = .* #/port = 5432 /' "${file}"
#--- Fix permissions - 'could not translate host name "localhost", service "5432" to address: Name or service not known'
chmod 0644 /etc/hosts
#--- Start services
systemctl stop postgresql
systemctl start postgresql
msfdb reinit
sleep 5s
#--- Autorun Metasploit commands each startup
file=~/.msf4/msf_autorunscript.rc; [ -e "${file}" ] && cp -n $file{,.bkup}
if [[ -f "${file}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${file} detected. Skipping..." 1>&2
else
  cat <<EOF > "${file}"
run post/windows/escalate/getsystem

#run migrate -f -k
#run migrate -n "explorer.exe" -k    # Can trigger AV alerts by touching explorer.exe...

run post/windows/manage/smart_migrate
run post/windows/gather/smart_hashdump
EOF
fi
file=~/.msf4/msfconsole.rc; [ -e "${file}" ] && cp -n $file{,.bkup}
if [[ -f "${file}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${file} detected. Skipping..." 1>&2
else
  cat <<EOF > "${file}"

load alias
alias del rm
alias handler use exploit/multi/handler

load sounds

setg TimestampOutput true
setg VERBOSE true

EOF
#setg AutoRunScript 'multi_console_command -rc "~/.msf4/msf_autorunscript.rc"'
fi
#--- First time run with Metasploit
(( STAGE++ )); echo -e " ${GREEN}[i]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Starting Metasploit for the first time${RESET} ~ this ${BOLD}will take a ~350 seconds${RESET} (~6 mintues)"
echo "Started at: $(date)"
systemctl start postgresql
msfdb start
msfconsole -x 'version;db_status;sleep 310;exit'


##### Install exe2hex
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exe2hex${RESET} ~ Inline file transfer"
apt -y -qq install exe2hexbat \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install MPC
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MPC${RESET} ~ Msfvenom Payload Creator"
apt -y -qq install msfpc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install wdiff
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wdiff${RESET} ~ Compares two files word by word"
apt -y -qq install wdiff wdiff-doc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install vbindiff
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vbindiff${RESET} ~ visually compare binary files"
apt -y -qq install vbindiff \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2



##### Install vFeed
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vFeed${RESET} ~ vulnerability database"
apt -y -qq install vfeed \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Burp Suite
if [[ "${burpFree}" != "false" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Burp Suite (Community Edition)${RESET} ~ web application proxy"
  apt -y -qq install burpsuite curl \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
  mkdir -p ~/.java/.userPrefs/burp/
  file=~/.java/.userPrefs/burp/prefs.xml;   #[ -e "${file}" ] && cp -n $file{,.bkup}
  [ -e "${file}" ] \
    || cat <<EOF > "${file}"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd" >
<map MAP_XML_VERSION="1.0">
  <entry key="eulafree" value="2"/>
  <entry key="free.suite.feedbackReportingEnabled" value="false"/>
</map>
EOF
  #--- Extract CA
  find /tmp/ -maxdepth 1 -name 'burp*.tmp' -delete
  export DISPLAY=:0.0
  timeout 120 burpsuite >/dev/null 2>&1 &
  PID=$!
  sleep 15s
  #echo "-----BEGIN CERTIFICATE-----" > /tmp/PortSwiggerCA \
  #  && awk -F '"' '/caCert/ {print $4}' ~/.java/.userPrefs/burp/prefs.xml | fold -w 64 >> /tmp/PortSwiggerCA \
  #  && echo "-----END CERTIFICATE-----" >> /tmp/PortSwiggerCA
  export http_proxy="http://127.0.0.1:8080"
  rm -f /tmp/burp.crt
  while test -d /proc/${PID}; do
    sleep 1s
    curl --progress -k -L -f "http://burp/cert" -o /tmp/burp.crt 2>/dev/null      # || echo -e ' '${RED}'[!]'${RESET}" Issue downloading burp.crt" 1>&2
    [ -f /tmp/burp.crt ] && break
  done
  timeout 5 kill ${PID} 2>/dev/null \
    || echo -e ' '${RED}'[!]'${RESET}" Failed to kill ${RED}burpsuite${RESET}"
  unset http_proxy
  #--- Installing CA
  if [[ -f /tmp/burp.crt ]]; then
    apt -y -qq install libnss3-tools \
      || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
    folder=$(find ~/.mozilla/firefox/ -maxdepth 1 -type d -name '*.default' -print -quit)
    certutil -A -n Burp -t "CT,c,c" -d "${folder}" -i /tmp/burp.crt
    timeout 15 firefox >/dev/null 2>&1
    timeout 5 killall -9 -q -w firefox-esr >/dev/null
    mkdir -p /usr/share/ca-certificates/burp/
    cp -f /tmp/burp.crt /usr/share/ca-certificates/burp/
    dpkg-reconfigure ca-certificates    # Not automated
    echo -e " ${YELLOW}[i]${RESET} Installed ${YELLOW}Burp Suite CA${RESET}"
  else
    echo -e ' '${RED}'[!]'${RESET}' Did not install Burp Suite Certificate Authority (CA)' 1>&2
    echo -e ' '${RED}'[!]'${RESET}' Skipping...' 1>&2
  fi
  #--- Remove old temp files
  sleep 2s
  find /tmp/ -maxdepth 1 -name 'burp*.tmp' -delete 2>/dev/null
  find ~/.mozilla/firefox/*.default*/ -maxdepth 1 -type f -name 'sessionstore.*' -delete
  unset http_proxy
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping Burp Suite${RESET} (missing: '$0 ${BOLD}--burp${RESET}')..." 1>&2
fi



##### Install virtualenvwrapper
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}virtualenvwrapper${RESET} ~ virtual environment wrapper"
apt -y -qq install virtualenvwrapper \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install go
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}go${RESET} ~ programming language"
apt -y -qq install golang \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install gitg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gitg${RESET} ~ GUI git client"
apt -y -qq install gitg \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install sparta
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sparta${RESET} ~ GUI automatic wrapper"
apt -y -qq install sparta \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install wireshark
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Wireshark${RESET} ~ GUI network protocol analyzer"
#--- Hide running as root warning
mkdir -p ~/.wireshark/
file=~/.wireshark/recent_common;   #[ -e "${file}" ] && cp -n $file{,.bkup}
[ -e "${file}" ] \
  || echo "privs.warn_if_elevated: FALSE" > "${file}"
#--- Disable lua warning
[ -e "/usr/share/wireshark/init.lua" ] \
  && mv -f /usr/share/wireshark/init.lua{,.disabled}


##### Install silver searcher
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}silver searcher${RESET} ~ code searching"
apt -y -qq install silversearcher-ag \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install rips
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rips${RESET} ~ source code scanner"
apt -y -qq install apache2 php git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/ripsscanner/rips.git /opt/rips-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/rips-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
file=/etc/apache2/conf-available/rips.conf
[ -e "${file}" ] \
  || cat <<EOF > "${file}"
Alias /rips /opt/rips-git

<Directory /opt/rips-git/ >
  Options FollowSymLinks
  AllowOverride None
  Order deny,allow
  Deny from all
  Allow from 127.0.0.0/255.0.0.0 ::1/128
</Directory>
EOF
ln -sf /etc/apache2/conf-available/rips.conf /etc/apache2/conf-enabled/rips.conf
systemctl restart apache2


##### Install graudit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}graudit${RESET} ~ source code auditing"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/wireghoul/graudit.git /opt/graudit-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/graudit-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/graudit-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/graudit-git/ && bash graudit.sh "\$@"
EOF
chmod +x "${file}"



##### Install asciinema
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}asciinema${RESET} ~ CLI terminal recorder"
curl -s -L https://asciinema.org/install | sh


##### Install shutter
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shutter${RESET} ~ GUI static screen capture"
apt -y -qq install shutter \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install psmisc ~ allows for 'killall command' to be used
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}psmisc${RESET} ~ suite to help with running processes"
apt -y -qq install psmisc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Setup pipe viewer
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pipe viewer${RESET} ~ CLI progress bar"
apt -y -qq install pv \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


###### Setup pwgen
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pwgen${RESET} ~ password generator"
apt -y -qq install pwgen \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install htop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htop${RESET} ~ CLI process viewer"
apt -y -qq install htop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install powertop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}powertop${RESET} ~ CLI power consumption viewer"
apt -y -qq install powertop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install iotop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}iotop${RESET} ~ CLI I/O usage"
apt -y -qq install iotop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install ca-certificates
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ca-certificates${RESET} ~ HTTPS/SSL/TLS"
apt -y -qq install ca-certificates \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install testssl
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}testssl${RESET} ~ Testing TLS/SSL encryption"
apt -y -qq install testssl.sh \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install UACScript
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}UACScript${RESET} ~ UAC Bypass for Windows 7"
apt -y -qq install git windows-binaries \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/Vozzie/uacscript.git /opt/uacscript-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/uacscript-git/ >/dev/null
git pull -q
popd >/dev/null
ln -sf /usr/share/windows-binaries/uac-win7 /opt/uacscript-git/


##### Install axel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}axel${RESET} ~ CLI download manager"
apt -y -qq install axel \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^alias axel' "${file}" 2>/dev/null \
  || echo -e '## axel\nalias axel="axel -a"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc


##### Install html2text
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}html2text${RESET} ~ CLI html rendering"
apt -y -qq install html2text \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install p7zip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}p7zip${RESET} ~ CLI file extractor"
apt -y -qq install p7zip-full \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install zip & unzip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}zip${RESET} & ${GREEN}unzip${RESET} ~ CLI file extractors"
apt -y -qq install zip unzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install file roller
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}file roller${RESET} ~ GUI file extractor"
apt -y -qq install file-roller \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
apt -y -qq install unace unrar rar unzip zip p7zip p7zip-full p7zip-rar \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install VPN support
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VPN${RESET} support for Network-Manager"
for FILE in network-manager-openvpn network-manager-pptp network-manager-vpnc network-manager-openconnect network-manager-iodine; do
  apt -y -qq install "${FILE}" \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
done


##### Install hashid
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}hashid${RESET} ~ identify hash types"
apt -y -qq install hashid \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install httprint
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}httprint${RESET} ~ GUI web server fingerprint"
apt -y -qq install httprint \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install lbd
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}lbd${RESET} ~ load balancing detector"
apt -y -qq install lbd \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install wafw00f
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wafw00f${RESET} ~ WAF detector"
apt -y -qq install wafw00f \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install aircrack-ng
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Aircrack-ng${RESET} ~ Wi-Fi cracking suite"
apt -y -qq install aircrack-ng curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup hardware database
mkdir -p /etc/aircrack-ng/
(timeout 600 airodump-ng-oui-update 2>/dev/null) \
  || timeout 600 curl --progress -k -L -f "http://standards-oui.ieee.org/oui/oui.txt" > /etc/aircrack-ng/oui.txt
[ -e /etc/aircrack-ng/oui.txt ] \
  && (\grep "(hex)" /etc/aircrack-ng/oui.txt | sed 's/^[ \t]*//g;s/[ \t]*$//g' > /etc/aircrack-ng/airodump-ng-oui.txt)
[[ ! -f /etc/aircrack-ng/airodump-ng-oui.txt ]] \
  && echo -e ' '${RED}'[!]'${RESET}" Issue downloading oui.txt" 1>&2
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## aircrack-ng' "${file}" 2>/dev/null \
  || echo -e '## aircrack-ng\nalias aircrack-ng="aircrack-ng -z"\n' >> "${file}"
grep -q '^## airodump-ng' "${file}" 2>/dev/null \
  || echo -e '## airodump-ng \nalias airodump-ng="airodump-ng --manufacturer --wps --uptime"\n' >> "${file}"    # aircrack-ng 1.2 rc2
#--- Apply new alias
source "${file}" || source ~/.zshrc



##### Install vulscan script for nmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vulscan script for nmap${RESET} ~ vulnerability scanner add-on"
apt -y -qq install nmap curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /usr/share/nmap/scripts/vulscan/
timeout 300 curl --progress -k -L -f "http://www.computec.ch/projekte/vulscan/download/nmap_nse_vulscan-2.0.tar.gz" > /tmp/nmap_nse_vulscan.tar.gz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading file" 1>&2      #***!!! hardcoded version! Need to manually check for updates
gunzip /tmp/nmap_nse_vulscan.tar.gz
tar -xf /tmp/nmap_nse_vulscan.tar -C /usr/share/nmap/scripts/
#--- Fix permissions (by default its 0777)
chmod -R 0755 /usr/share/nmap/scripts/; find /usr/share/nmap/scripts/ -type f -exec chmod 0644 {} \;


##### Install unicornscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}unicornscan${RESET} ~ fast port scanner"
apt -y -qq install unicornscan \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install onetwopunch
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}onetwopunch${RESET} ~ unicornscan & nmap wrapper"
apt -y -qq install git nmap unicornscan \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/superkojiman/onetwopunch.git /opt/onetwopunch-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/onetwopunch-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/onetwopunch-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/onetwopunch-git/ && bash onetwopunch.sh "\$@"
EOF
chmod +x "${file}"


##### Install Gnmap-Parser (fork)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Gnmap-Parser (fork)${RESET} ~ Parse Nmap exports into various plain-text formats"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/nullmode/gnmap-parser.git /opt/gnmap-parser-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/gnmap-parser-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
chmod +x /opt/gnmap-parser-git/gnmap-parser.sh
mkdir -p /usr/local/bin/
ln -sf /opt/gnmap-parser-git/gnmap-parser.sh /usr/local/bin/gnmap-parser-git


##### Install udp-proto-scanner
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}udp-proto-scanner${RESET} ~ common UDP port scanner"
apt -y -qq install curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
timeout 300 curl --progress -k -L -f "https://labs.portcullis.co.uk/download/udp-proto-scanner-1.1.tar.gz" -o /tmp/udp-proto-scanner.tar.gz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading udp-proto-scanner.tar.gz" 1>&2
gunzip /tmp/udp-proto-scanner.tar.gz
tar -xf /tmp/udp-proto-scanner.tar -C /opt/
mv -f /opt/udp-proto-scanner{-1.1,}
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/udp-proto-scanner
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/udp-proto-scanner/ && perl udp-proto-scanner.pl "\$@"
EOF
chmod +x "${file}"


##### Install clusterd
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}clusterd${RESET} ~ clustered attack toolkit (JBoss, ColdFusion, WebLogic, Tomcat etc)"
apt -y -qq install clusterd \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install webhandler
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}webhandler${RESET} ~ shell TTY handler"
apt -y -qq install webhandler \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Add to path
mkdir -p /usr/local/bin/
ln -sf /usr/bin/webhandler /usr/local/bin/wh


##### Install azazel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}azazel${RESET} ~ Linux userland rootkit"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/chokepoint/azazel.git /opt/azazel-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/azazel-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install Babadook
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babadook${RESET} ~ connection-less powershell backdoor"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/jseidl/Babadook.git /opt/babadook-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/babadook-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install pupy
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pupy${RESET} ~ Remote Administration Tool"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/n1nj4sec/pupy.git /opt/pupy-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/pupy-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install gobuster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gobuster${RESET} ~ Directory/File/DNS busting tool"
apt -y -qq install git gobuster \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install reGeorg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}reGeorg${RESET} ~ pivot via web shells"
git clone -q -b master https://github.com/sensepost/reGeorg.git /opt/regeorg-git \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/regeorg-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Link to others
apt -y -qq install webshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf /opt/reGeorg-git /usr/share/webshells/reGeorg


##### Install b374k (https://bugs.kali.org/view.php?id=1097)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}b374k${RESET} ~ (PHP) web shell"
apt -y -qq install git php-cli \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/b374k/b374k.git /opt/b374k-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/b374k-git/ >/dev/null
git pull -q
php index.php -o b374k.php -s
popd >/dev/null
#--- Link to others
apt -y -qq install webshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf /opt/b374k-git /usr/share/webshells/php/b374k


##### Install adminer
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}adminer${RESET} ~ Database management in a single PHP file"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/vrana/adminer.git /opt/adminer-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/adminer-git/ >/dev/null
git pull -q
php compile.php 2>/dev/null
popd >/dev/null
#--- Link to others
apt -y -qq install webshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
file=$(find /opt/adminer-git/ -name adminer-*.php -type f -print -quit)
ln -sf "${file}" /usr/share/webshells/php/adminer.php


##### Install WeBaCoo
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WeBaCoo${RESET} ~ Web backdoor cookie"
apt -y -qq install webacoo \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install cmdsql
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}cmdsql${RESET} ~ (ASPX) web shell"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/NetSPI/cmdsql.git /opt/cmdsql-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/cmdsql-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Link to others
apt -y -qq install webshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf /opt/cmdsql-git /usr/share/webshells/aspx/cmdsql


##### Install JSP file browser
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}JSP file browser${RESET} ~ (JSP) web shell"
apt -y -qq install curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /opt/jsp-filebrowser/
timeout 300 curl --progress -k -L -f "http://www.vonloesch.de/files/browser.zip" > /tmp/jsp.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading jsp.zip" 1>&2
unzip -q -o -d /opt/jsp-filebrowser/ /tmp/jsp.zip
#--- Link to others
apt -y -qq install webshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf /opt/jsp-filebrowser /usr/share/webshells/jsp/jsp-filebrowser


##### Install htshells
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htShells${RESET} ~ (htdocs/apache) web shells"
apt -y -qq install htshells \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install python-pty-shells
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}python-pty-shells${RESET} ~ PTY shells"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/infodox/python-pty-shells.git /opt/python-pty-shells-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/python-pty-shells-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install bridge-utils
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bridge-utils${RESET} ~ Bridge network interfaces"
apt -y -qq install bridge-utils \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2



##### Install proxychains-ng (https://bugs.kali.org/view.php?id=2037)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}proxychains-ng${RESET} ~ Proxifier"
apt -y -qq install git gcc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/rofl0r/proxychains-ng.git /opt/proxychains-ng-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/proxychains-ng-git/ >/dev/null
git pull -q
make -s clean
./configure --prefix=/usr --sysconfdir=/etc >/dev/null
make -s 2>/dev/null && make -s install   # bad, but it gives errors which might be confusing (still builds)
popd >/dev/null
#--- Add to path (with a 'better' name)
mkdir -p /usr/local/bin/
ln -sf /usr/bin/proxychains4 /usr/local/bin/proxychains-ng


##### Install httptunnel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}httptunnel${RESET} ~ Tunnels data streams in HTTP requests"
apt -y -qq install http-tunnel \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install sshuttle
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sshuttle${RESET} ~ VPN over SSH"
apt -y -qq install sshuttle \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Example
#sshuttle --dns --remote root@123.9.9.9 0/0 -vv


##### Install pfi
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pfi${RESET} ~ Port Forwarding Interceptor"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/s7ephen/pfi.git /opt/pfi-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/pfi-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install icmpsh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}icmpsh${RESET} ~ Reverse ICMP shell"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/inquisb/icmpsh.git /opt/icmpsh-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/icmpsh-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install dnsftp
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dnsftp${RESET} ~ Transfer files over DNS"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/breenmachine/dnsftp.git /opt/dnsftp-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/dnsftp-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install iodine
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}iodine${RESET} ~ DNS tunnelling (IP over DNS)"
apt -y -qq install iodine \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#iodined -f -P password1 10.0.0.1 dns.mydomain.com
#iodine -f -P password1 123.9.9.9 dns.mydomain.com; ssh -C -D 8081 root@10.0.0.1


##### Install dns2tcp
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dns2tcp${RESET} ~ DNS tunnelling (TCP over DNS)"
apt -y -qq install dns2tcp \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Daemon
file=/etc/dns2tcpd.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
listen = 0.0.0.0
port = 53
user = nobody
chroot = /tmp
domain = dnstunnel.mydomain.com
key = password1
ressources = ssh:127.0.0.1:22
EOF
#--- Client
file=/etc/dns2tcpc.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
domain = dnstunnel.mydomain.com
key = password1
resources = ssh
local_port = 8000
debug_level=1
EOF
#--- Example
#dns2tcpd -F -d 1 -f /etc/dns2tcpd.conf
#dns2tcpc -f /etc/dns2tcpc.conf 178.62.206.227; ssh -C -D 8081 -p 8000 root@127.0.0.1


##### Install ptunnel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ptunnel${RESET} ~ ICMP tunnelling"
apt -y -qq install ptunnel \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Example
#ptunnel -x password1
#ptunnel -x password1 -p 123.9.9.9 -lp 8000 -da 127.0.0.1 -dp 22; ssh -C -D 8081 -p 8000 root@127.0.0.1


##### Install stunnel
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}stunnel${RESET} ~ SSL wrapper"
apt -y -qq install stunnel \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Remove from start up
systemctl disable stunnel4



##### Install gcc & multilib
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gcc${RESET} & ${GREEN}multilibc${RESET} ~ compiling libraries"
for FILE in cc gcc g++ gcc-multilib make automake libc6 libc6-dev libc6-amd64 libc6-dev-amd64 libc6-i386 libc6-dev-i386 libc6-i686 libc6-dev-i686 build-essential dpkg-dev; do
  apt -y -qq install "${FILE}" 2>/dev/null
done


##### Install MinGW ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW${RESET} ~ cross compiling suite"
for FILE in mingw-w64 binutils-mingw-w64 gcc-mingw-w64 cmake   mingw-w64-dev mingw-w64-tools   gcc-mingw-w64-i686 gcc-mingw-w64-x86-64   mingw32; do
  apt -y -qq install "${FILE}" 2>/dev/null
done


##### Install WINE
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
apt -y -qq install wine winetricks \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Using x64?
if [[ "$(uname -m)" == 'x86_64' ]]; then
  (( STAGE++ )); echo -e " ${GREEN}[i]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}WINE (x64)${RESET}"
  dpkg --add-architecture i386
  apt -qq update
  apt -y -qq install wine32 \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi
#--- Run WINE for the first time
[ -e /usr/share/windows-binaries/whoami.exe ] && wine /usr/share/windows-binaries/whoami.exe &>/dev/null
#--- Setup default file association for .exe
file=~/.local/share/applications/mimeapps.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
echo -e 'application/x-ms-dos-executable=wine.desktop' >> "${file}"


##### Install MinGW (Windows) ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW (Windows)${RESET} ~ cross compiling suite"
apt -y -qq install wine curl unzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
timeout 300 curl --progress -k -L -f "http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download" > /tmp/mingw-get.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading mingw-get.zip" 1>&2       #***!!! hardcoded path!
mkdir -p ~/.wine/drive_c/MinGW/bin/
unzip -q -o -d ~/.wine/drive_c/MinGW/ /tmp/mingw-get.zip
pushd ~/.wine/drive_c/MinGW/ >/dev/null
for FILE in mingw32-base mingw32-gcc-g++ mingw32-gcc-objc; do   #msys-base
  wine ./bin/mingw-get.exe install "${FILE}" 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
done
popd >/dev/null
#--- Add to windows path
grep -q '^"PATH"=.*C:\\\\MinGW\\\\bin' ~/.wine/system.reg \
  || sed -i '/^"PATH"=/ s_"$_;C:\\\\MinGW\\\\bin"_' ~/.wine/system.reg


##### Downloading AccessChk.exe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}AccessChk.exe${RESET} ~ Windows environment tester"
apt -y -qq install curl windows-binaries unzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
echo -n '[1/2]'; timeout 300 curl --progress -k -L -f "https://web.archive.org/web/20080530012252/http://live.sysinternals.com/accesschk.exe" > /usr/share/windows-binaries/accesschk_v5.02.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading accesschk_v5.02.exe" 1>&2   #***!!! hardcoded path!
echo -n '[2/2]'; timeout 300 curl --progress -k -L -f "https://download.sysinternals.com/files/AccessChk.zip" > /usr/share/windows-binaries/AccessChk.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading AccessChk.zip" 1>&2
unzip -q -o -d /usr/share/windows-binaries/ /usr/share/windows-binaries/AccessChk.zip
rm -f /usr/share/windows-binaries/{AccessChk.zip,Eula.txt}


##### Downloading PsExec.exe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}PsExec.exe${RESET} ~ Pass The Hash 'phun'"
apt -y -qq install curl windows-binaries unzip unrar \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
echo -n '[1/2]'; timeout 300 curl --progress -k -L -f "https://download.sysinternals.com/files/PSTools.zip" > /tmp/pstools.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pstools.zip" 1>&2
echo -n '[2/2]'; timeout 300 curl --progress -k -L -f "http://www.coresecurity.com/system/files/pshtoolkit_v1.4.rar" > /tmp/pshtoolkit.rar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pshtoolkit.rar" 1>&2  #***!!! hardcoded path!
unzip -q -o -d /usr/share/windows-binaries/pstools/ /tmp/pstools.zip
unrar x -y /tmp/pshtoolkit.rar /usr/share/windows-binaries/ >/dev/null


##### Install Python (Windows via WINE)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Python (Windows)${RESET}"
echo -n '[1/2]'; timeout 300 curl --progress -k -L -f "https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi" > /tmp/python.msi \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading python.msi" 1>&2       #***!!! hardcoded path!
echo -n '[2/2]'; timeout 300 curl --progress -k -L -f "http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download" > /tmp/pywin32.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pywin32.exe" 1>&2      #***!!! hardcoded path!
wine msiexec /i /tmp/python.msi /qb 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
pushd /tmp/ >/dev/null
rm -rf "PLATLIB/" "SCRIPTS/"
unzip -q -o /tmp/pywin32.exe
cp -rf PLATLIB/* ~/.wine/drive_c/Python27/Lib/site-packages/
cp -rf SCRIPTS/* ~/.wine/drive_c/Python27/Scripts/
rm -rf "PLATLIB/" "SCRIPTS/"
popd >/dev/null


##### Install veil framework
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}veil-evasion framework${RESET} ~ bypassing anti-virus"
apt -y -qq install veil-evasion \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#bash /usr/share/veil-evasion/setup/setup.sh --silent
mkdir -p /var/lib/veil-evasion/go/bin/
touch /etc/veil/settings.py
sed -i 's/TERMINAL_CLEAR=".*"/TERMINAL_CLEAR="false"/' /etc/veil/settings.py


##### Install OP packers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}OP packers${RESET} ~ bypassing anti-virus"
apt -y -qq install upx-ucl curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /opt/packers/
echo -n '[1/3]'; timeout 300 curl --progress -k -L -f "http://www.eskimo.com/~scottlu/win/cexe.exe" > /opt/packers/cexe.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading cexe.exe" 1>&2            #***!!! hardcoded version! Need to manually check for updates
echo -n '[2/3]'; timeout 300 curl --progress -k -L -f "http://www.farbrausch.de/~fg/kkrunchy/kkrunchy_023a2.zip" > /opt/packers/kkrunchy.zip \
  && unzip -q -o -d /opt/packers/ /opt/packers/kkrunchy.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading kkrunchy.zip" 1>&2        #***!!! hardcoded version! Need to manually check for updates
echo -n '[3/3]'; timeout 300 curl --progress -k -L -f "https://github.com/Veil-Framework/Veil-Evasion/blob/master/tools/pescrambler/PEScrambler.exe" > /opt/packers/PEScrambler \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading PEScrambler.exe" 1>&2     #***!!! hardcoded version! Need to manually check for updates
#*** ??????? Need to make a bash script like hyperion...
#--- Link to others
apt -y -qq install windows-binaries \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf /opt/packers/ /usr/share/windows-binaries/packers


##### Install hyperion
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}hyperion${RESET} ~ bypassing anti-virus"
apt -y -qq install unzip windows-binaries \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
unzip -q -o -d /usr/share/windows-binaries/ $(find /usr/share/windows-binaries/ -name "Hyperion-*.zip" -type f -print -quit)
#--- Compile
i686-w64-mingw32-g++ -static-libgcc -static-libstdc++ \
  /usr/share/windows-binaries/Hyperion-1.0/Src/Crypter/*.cpp \
  -o /usr/share/windows-binaries/Hyperion-1.0/Src/Crypter/bin/crypter.exe
ln -sf /usr/share/windows-binaries/Hyperion-1.0/Src/Crypter/bin/crypter.exe /usr/share/windows-binaries/Hyperion-1.0/crypter.exe                                                            #***!!! hardcoded path!
wine ~/.wine/drive_c/MinGW/bin/g++.exe /usr/share/windows-binaries/Hyperion-1.0/Src/Crypter/*.cpp \
  -o /usr/share/windows-binaries/hyperion.exe 2>&1 \
  | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/hyperion
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

## Note: This is far from perfect...

CWD=\$(pwd)/
BWD="?"

## Using full path?
[ -e "/\${1}" ] && BWD=""

## Using relative path?
[ -e "./\${1}" ] && BWD="\${CWD}"

## Can't find input file!
[[ "\${BWD}" == "?" ]] && echo -e ' '${RED}'[!]'${RESET}' Cant find \$1. Quitting...' && exit

## The magic!
cd /usr/share/windows-binaries/Hyperion-1.0/
$(which wine) ./Src/Crypter/bin/crypter.exe \${BWD}\${1} output.exe

## Restore our path
cd \${CWD}/
sleep 1s

## Move the output file
mv -f /usr/share/windows-binaries/Hyperion-1.0/output.exe \${2}

## Generate file hashes
for FILE in \${1} \${2}; do
  echo "[i] \$(md5sum \${FILE})"
done
EOF
chmod +x "${file}"


##### Install shellter
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellter${RESET} ~ dynamic shellcode injector"
apt -y -qq install shellter \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install the backdoor factory
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Backdoor Factory${RESET} ~ bypassing anti-virus"
apt -y -qq install backdoor-factory \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Backdoor Factory Proxy (BDFProxy)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Backdoor Factory Proxy (BDFProxy)${RESET} ~ patches binaries files during a MITM"
apt -y -qq install bdfproxy \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install BetterCap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}BetterCap${RESET} ~ MITM framework"
apt -y -qq install git ruby-dev libpcap-dev \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/evilsocket/bettercap.git /opt/bettercap-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/bettercap-git/ >/dev/null
git pull -q
gem build bettercap.gemspec
gem install bettercap*.gem
popd >/dev/null


##### Install mitmf
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MITMf${RESET} ~ framework for MITM attacks"
apt -y -qq install mitmf \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install responder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Responder${RESET} ~ rogue server"
apt -y -qq install responder \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install seclist
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}seclist${RESET} ~ multiple types of (word)lists (and similar things)"
apt -y -qq install seclists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Link to others
apt -y -qq install wordlists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
[ -e /usr/share/seclists ] \
  && ln -sf /usr/share/seclists /usr/share/wordlists/seclists

#  https://github.com/fuzzdb-project/fuzzdb


##### Update wordlists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}wordlists${RESET} ~ collection of wordlists"
apt -y -qq install wordlists curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Extract rockyou wordlist
[ -e /usr/share/wordlists/rockyou.txt.gz ] \
  && gzip -dc < /usr/share/wordlists/rockyou.txt.gz > /usr/share/wordlists/rockyou.txt
#--- Add 10,000 Top/Worst/Common Passwords
mkdir -p /usr/share/wordlists/
(curl --progress -k -L -f "http://xato.net/files/10k most common.zip" > /tmp/10kcommon.zip 2>/dev/null \
  || curl --progress -k -L -f "http://download.g0tmi1k.com/wordlists/common-10k_most_common.zip" > /tmp/10kcommon.zip 2>/dev/null) \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading 10kcommon.zip" 1>&2
unzip -q -o -d /usr/share/wordlists/ /tmp/10kcommon.zip 2>/dev/null   #***!!! hardcoded version! Need to manually check for updates
mv -f /usr/share/wordlists/10k{\ most\ ,_most_}common.txt
#--- Linking to more - folders
[ -e /usr/share/dirb/wordlists ] \
  && ln -sf /usr/share/dirb/wordlists /usr/share/wordlists/dirb
#--- Extract sqlmap wordlist
unzip -o -d /usr/share/sqlmap/txt/ /usr/share/sqlmap/txt/wordlist.zip
ln -sf /usr/share/sqlmap/txt/wordlist.txt /usr/share/wordlists/sqlmap.txt
#--- Not enough? Want more? Check below!
#apt search wordlist
#find / \( -iname '*wordlist*' -or -iname '*passwords*' \) #-exec ls -l {} \;


##### Install apt-file
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apt-file${RESET} ~ which package includes a specific file"
apt -y -qq install apt-file \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
apt-file update


##### Install apt-show-versions
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apt-show-versions${RESET} ~ which package version in repo"
apt -y -qq install apt-show-versions \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Babel scripts
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babel scripts${RESET} ~ post exploitation scripts"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/attackdebris/babel-sf.git /opt/babel-sf-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/babel-sf-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install checksec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}checksec${RESET} ~ check *nix OS for security features"
apt -y -qq install curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /usr/share/checksec/
file=/usr/share/checksec/checksec.sh
timeout 300 curl --progress -k -L -f "http://www.trapkit.de/tools/checksec.sh" > "${file}" \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading checksec.sh" 1>&2     #***!!! hardcoded patch
chmod +x "${file}"


##### Install shellconv
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellconv${RESET} ~ shellcode disassembler"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/hasherezade/shellconv.git /opt/shellconv-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/shellconv-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/shellconv-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/shellconv-git/ && python shellconv.py "\$@"
EOF
chmod +x "${file}"



##### Install dhex
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dhex${RESET} ~ CLI hex compare"
apt -y -qq install dhex \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2



##### Install lnav
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}lnav${RESET} ~ CLI log veiwer"
apt -y -qq install lnav \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install commix
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}commix${RESET} ~ automatic command injection"
apt -y -qq install commix \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install fimap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}fimap${RESET} ~ automatic LFI/RFI tool"
apt -y -qq install fimap \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install smbmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}smbmap${RESET} ~ SMB enumeration tool"
apt -y -qq install smbmap \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install smbspider
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}smbspider${RESET} ~ search network shares"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/T-S-A/smbspider.git /opt/smbspider-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/smbspider-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install CrackMapExec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec${RESET} ~ Swiss army knife for Windows environments"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/byt3bl33d3r/CrackMapExec.git /opt/crackmapexec-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/crackmapexec-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install credcrack
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}credcrack${RESET} ~ credential harvester via Samba"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/gojhonny/CredCrack.git /opt/credcrack-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/credcrack-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install Empire
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/PowerShellEmpire/Empire.git /opt/empire-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/empire-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install wig (https://bugs.kali.org/view.php?id=1932)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wig${RESET} ~ web application detection"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/jekyc/wig.git /opt/wig-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/wig-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/wig-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/wig-git/ && python wig.py "\$@"
EOF
chmod +x "${file}"


##### Install CMSmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CMSmap${RESET} ~ CMS detection"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/Dionach/CMSmap.git /opt/cmsmap-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/cmsmap-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/cmsmap-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/cmsmap-git/ && python cmsmap.py "\$@"
EOF
chmod +x "${file}"


##### Install droopescan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DroopeScan${RESET} ~ Drupal vulnerability scanner"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/droope/droopescan.git /opt/droopescan-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/droopescan-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/droopescan-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/droopescan-git/ && python droopescan "\$@"
EOF
chmod +x "${file}"



##### Install patator (GIT)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}patator${RESET} (GIT) ~ brute force"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/lanjelot/patator.git /opt/patator-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/patator-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/patator-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/patator-git/ && python patator.py "\$@"
EOF
chmod +x "${file}"


##### Install crowbar
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}crowbar${RESET} ~ brute force"
apt -y -qq install git openvpn freerdp-x11 vncviewer \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/galkan/crowbar.git /opt/crowbar-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/crowbar-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/crowbar-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/crowbar-git/ && python crowbar.py "\$@"
EOF
chmod +x "${file}"


##### Install xprobe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}xprobe${RESET} ~ OS fingerprinting"
apt -y -qq install xprobe \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install p0f
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}p0f${RESET} ~ OS fingerprinting"
apt -y -qq install p0f \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#p0f -i eth0 -p & curl 192.168.0.1


##### Install nbtscan ~ http://unixwiz.net/tools/nbtscan.html vs http://inetcat.org/software/nbtscan.html (see http://sectools.org/tool/nbtscan/)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nbtscan${RESET} (${GREEN}inetcat${RESET} & ${GREEN}unixwiz${RESET}) ~ netbios scanner"
#--- inetcat - 1.5.x
apt -y -qq install nbtscan \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Examples
#nbtscan -r 192.168.0.1/24
#nbtscan -r 192.168.0.1/24 -v
#--- unixwiz - 1.0.x
mkdir -p /usr/local/src/nbtscan-unixwiz/
timeout 300 curl --progress -k -L -f "http://unixwiz.net/tools/nbtscan-source-1.0.35.tgz" > /usr/local/src/nbtscan-unixwiz/nbtscan.tgz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading nbtscan.tgz" 1>&2    #***!!! hardcoded version! Need to manually check for updates
tar -zxf /usr/local/src/nbtscan-unixwiz/nbtscan.tgz -C /usr/local/src/nbtscan-unixwiz/
pushd /usr/local/src/nbtscan-unixwiz/ >/dev/null
make -s clean;
make -s 2>/dev/null    # bad, I know
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
ln -sf /usr/local/src/nbtscan-unixwiz/nbtscan /usr/local/bin/nbtscan-uw
#--- Examples
#nbtscan-uw -f 192.168.0.1/24


##### Setup tftp client & server
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting up ${GREEN}tftp client${RESET} & ${GREEN}server${RESET} ~ file transfer methods"
apt -y -qq install tftp atftpd \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure atftpd
file=/etc/default/atftpd; [ -e "${file}" ] && cp -n $file{,.bkup}
echo -e 'USE_INETD=false\nOPTIONS="--tftpd-timeout 300 --retry-timeout 5 --maxthread 100 --verbose=5 --daemon --port 69 /var/tftp"' > "${file}"
mkdir -p /var/tftp/
chown -R nobody\:root /var/tftp/
chmod -R 0755 /var/tftp/
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## tftp' "${file}" 2>/dev/null \
  || echo -e '## tftp\nalias tftproot="cd /var/tftp/"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc
#--- Remove from start up
systemctl disable atftpd
#--- Disabling IPv6 can help
#echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
#echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6


##### Install rsh-client
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rsh-client${RESET} ~ remote shell connections"
apt -y -qq install rsh-client \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install sshpass
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sshpass${RESET} ~ automating SSH connections"
apt -y -qq install sshpass \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install DBeaver
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DBeaver${RESET} ~ GUI DB manager"
apt -y -qq install curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
arch="i386"
[[ "$(uname -m)" == "x86_64" ]] && arch="amd64"
timeout 300 curl --progress -k -L -f "http://dbeaver.jkiss.org/files/dbeaver-ce_latest_${arch}.deb" > /tmp/dbeaver.deb \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading dbeaver.deb" 1>&2   #***!!! hardcoded version! Need to manually check for updates
if [ -e /tmp/dbeaver.deb ]; then
  dpkg -i /tmp/dbeaver.deb
  #--- Add to path
  mkdir -p /usr/local/bin/
  ln -sf /usr/share/dbeaver/dbeaver /usr/local/bin/dbeaver
fi


##### Install ashttp
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ashttp${RESET} ~ terminal via the web"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/JulienPalard/ashttp.git /opt/ashttp-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/ashttp-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install gotty
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gotty${RESET} ~ terminal via the web"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/yudai/gotty.git /opt/gotty-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/gotty-git/ >/dev/null
git pull -q
popd >/dev/null


##### Preparing a jail ~ http://allanfeid.com/content/creating-chroot-jail-ssh-access // http://www.cyberciti.biz/files/lighttpd/l2chroot.txt
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Preparing up a ${GREEN}jail${RESET} ~ testing environment"
apt -y -qq install debootstrap curl \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting up ${GREEN}SSH${RESET} ~ CLI access"
apt -y -qq install openssh-server \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Wipe current keys
rm -f /etc/ssh/ssh_host_*
find ~/.ssh/ -type f ! -name authorized_keys -delete 2>/dev/null
#--- Generate new keys
ssh-keygen -b 4096 -t rsa1 -f /etc/ssh/ssh_host_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" >/dev/null
ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" >/dev/null
ssh-keygen -b 521 -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -P "" >/dev/null
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P "" >/dev/null
#--- Change MOTD
echo "..." | > /etc/motd
#--- Change SSH settings
file=/etc/ssh/sshd_config; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/g' "${file}"      # Accept password login (overwrite Debian 8+'s more secure default option...)
sed -i 's/^#AuthorizedKeysFile /AuthorizedKeysFile /g' "${file}"    # Allow for key based logins
#--- Setup alias (handy for 'zsh: correct 'ssh' to '.ssh' [nyae]? n')
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## ssh' "${file}" 2>/dev/null \
  || echo -e '## ssh\nalias ssh-start="systemctl restart ssh"\nalias ssh-stop="systemctl stop ssh"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc



##### Custom insert point

##### Install OpenVAS
if [[ "${openVAS}" != "false" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}OpenVAS${RESET} ~ vulnerability scanner"
  apt -y -qq install openvas \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
  openvas-setup
  #--- Bug fix (target credentials creation)
  mkdir -p /var/lib/openvas/gnupg/
  #--- Bug fix (keys)
  curl --progress -k -L -f "http://www.openvas.org/OpenVAS_TI.asc" | gpg --import - \
    || echo -e ' '${RED}'[!]'${RESET}" Issue downloading OpenVAS_TI.asc" 1>&2
  #--- Make sure all services are correct
  openvas-start
  #--- User control
  username="root"
  password="toor"
  (openvasmd --get-users | grep -q ^admin$) \
    && echo -n 'admin user: ' \
    && openvasmd --delete-user=admin
  (openvasmd --get-users | grep -q "^${username}$") \
    || (echo -n "${username} user: "; openvasmd --create-user="${username}"; openvasmd --user="${username}" --new-password="${password}" >/dev/null)
  echo -e " ${YELLOW}[i]${RESET} OpenVAS username: ${username}"
  echo -e " ${YELLOW}[i]${RESET} OpenVAS password: ${password}   ***${BOLD}CHANGE THIS ASAP${RESET}***"
  echo -e " ${YELLOW}[i]${RESET} Run: # openvasmd --user=root --new-password='<NEW_PASSWORD>'"
  sleep 3s
  openvas-check-setup
  #--- Remove from start up
  systemctl disable openvas-manager
  systemctl disable openvas-scanner
  systemctl disable greenbone-security-assistant
  #--- Setup alias
  file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
  grep -q '^## openvas' "${file}" 2>/dev/null \
    || echo -e '## openvas\nalias openvas="openvas-stop; openvas-start; sleep 3s; xdg-open https://127.0.0.1:9392/ >/dev/null 2>&1"\n' >> "${file}"
  source "${file}" || source ~/.zshrc
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping OpenVAS${RESET} (missing: '$0 ${BOLD}--openvas${RESET}')..." 1>&2
fi


##### copy bash aliases
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
#--- Clean package manager
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done
apt -y -qq purge $(dpkg -l | tail -n +6 | egrep -v '^(h|i)i' | awk '{print $2}')   # Purged packages
#--- Update slocate database
updatedb
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -cw 2>/dev/null
for i in $(cut -d: -f6 /etc/passwd | sort -u); do
  [ -e "${i}" ] && find "${i}" -type f -name '.*_history' -delete
done


##### Install The Backdoor Factory
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}The Backdoor Factory${RESET} ~ Patch PE, ELF, Mach-O binaries with shellcode."
git clone https://github.com/secretsquirrel/the-backdoor-factory /opt/the-backdoor-factory \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/the-backdoor-factory/ >/dev/null
./install.sh
popd >/dev/null


##### Install HTTPScreenShot
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}HTTPScreenShot${RESET} ~ a tool for grabbing screenshots and HTML of large numbers of websites."
git clone https://github.com/breenmachine/httpscreenshot.git /opt/httpscreenshot \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/httpscreenshot >/dev/null
chmod +x install-dependencies.sh && ./install-dependencies.sh
popd >/dev/null


##### Install Masscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Masscan${RESET} ~ the fastest Internet port scanner. It can scan the entire Internet in under six minutes."
apt-get install git gcc make libpcap-dev \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone https://github.com/robertdavidgraham/masscan.git /opt/masscan \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/masscan >/dev/null
make
make install
popd >/dev/null


##### Install Eyewitness
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Eyewitness${RESET} ~ take screenshots of websites, provide some server header info, and identify default credentials if possible"
git clone https://github.com/ChrisTruncer/EyeWitness.git /opt/EyeWitness \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install Responder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Responder${RESET} ~ A LLMNR, NBT-NS and MDNS poisoner, with built-in HTTP/SMB/MSSQL/FTP/LDAP rogue authentication server supporting NTLMv1/NTLMv2/LMv2, Extended Security NTLMSSP and Basic HTTP authentication. Responder will be used to gain NTLM challenge/response hashes"
git clone https://github.com/SpiderLabs/Responder.git /opt/Responder \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2

##### Install NoSQLMap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}NoSQLMap${RESET} ~ A automated pentesting toolset for MongoDB database servers and web applications."
git clone https://github.com/tcstool/NoSQLMap.git /opt/NoSQLMap \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install Discover Scripts
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Discover Scripts${RESET} ~ Custom bash scripts used to automate various pentesting tasks."
git clone https://github.com/leebaird/discover.git /opt/discover \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/discover >/dev/null
./update.sh
popd >/dev/null


##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
#--- Clean package manager
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done
apt -y -qq purge $(dpkg -l | tail -n +6 | egrep -v '^(h|i)i' | awk '{print $2}')   # Purged packages
#--- Update slocate database
updatedb
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -cw 2>/dev/null
for i in $(cut -d: -f6 /etc/passwd | sort -u); do
  [ -e "${i}" ] && find "${i}" -type f -name '.*_history' -delete
done


##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"
echo -e " ${YELLOW}[i]${RESET} Stages skipped: $(( TOTAL-STAGE ))"


#-Done-----------------------------------------------------------------#


##### Done!
echo -e "\n ${YELLOW}[i]${RESET} Don't forget to:"
echo -e " ${YELLOW}[i]${RESET} + Check the above output (Did everything install? Any errors? (${RED}HINT: What's in RED${RESET}?)"
echo -e " ${YELLOW}[i]${RESET} + Manually install: Nessus, Nexpose, and/or Metasploit Community"
echo -e " ${YELLOW}[i]${RESET} + Agree/Accept to: Maltego, OWASP ZAP, w3af, PyCharm, etc"
echo -e " ${YELLOW}[i]${RESET} + Setup git:   ${YELLOW}git config --global user.name <name>;git config --global user.email <email>${RESET}"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Change default passwords${RESET}: PostgreSQL/MSF, MySQL, OpenVAS, BeEF XSS, etc"
echo -e " ${YELLOW}[i]${RESET} + ${YELLOW}Reboot${RESET}"
(dmidecode | grep -iq virtual) \
  && echo -e " ${YELLOW}[i]${RESET} + Take a snapshot   (Virtual machine detected)"

echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
