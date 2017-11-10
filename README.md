# Post-installation script for Kali Linux

# Preliminary operations

Downloads the latest version and executes it

Parses and sets user supplied options

# Main operations
Checks if script is running as root - Else it fails

Fixes display output for GUI programs (when connecting via SSH)

Checks if desktop environment is GNOME, then:
    Disables auto notification package updater
    Disables screensaver

Checks Internet access

Checks GitHub is reachable

Enables default network repositories 

Checks if Kali is a VM. If so, Installs 'Virtual Machine Addons/Tools'

Sets static & protecting DNS name servers if supplied by user

Updates location information

Updates OS from network repositories

Installs kernel headers

Installs the 'Kali-Full' meta packages

Sets audio level to 25%

Configures GRUB

Configures GNOME ~ desktop environment

Configures file ~ GUI file system navigation

Configures GNOME terminal ~ CLI interface

Configures bash ~ CLI shell

Installs bash colour ~ colours shell output

Installs grc ~ colours shell output

Configures aliases for the root user

Installs ZSH & Oh-My-ZSH for the root user

Installs tmux ~ multiplex virtual consoles

Configures screen ~ multiplex virtual consoles

Installs and Configures vim ~ CLI text editor

Installs git ~ revision control

Configures Firefox

Installs and Configures Metasploit ~ exploit framework

Installs exe2hex ~ Inline file transfer

Installs MPC ~ Msfvenom Payload Creator

Configures Gedit ~ GUI text editor

Installs PyCharm ~ Python IDE

Installs wdiff ~ Compares two files word by word

Installs meld ~ GUI text compare

Installs vbindiff ~ visually compare binary files

Installs vFeed ~ vulnerability database

Installs Burp Suite

Installs virtualenvwrapper ~ virtual environment wrapper

Installs go ~ programming language

Installs gitg ~ GUI git client

Installs sparta ~ GUI automatic wrapper

Installs Wireshark ~ GUI network protocol analyzer

Installs silver searcher ~ code searching

Installs rips ~ source code scanner

Installs graudit ~ source code auditing

Installs asciinema ~ CLI terminal recorder

Installs shutter ~ GUI static screen capture

Installs psmisc ~ suite to help with running processes

Setup pipe viewer ~ CLI progress bar

Setup pwgen ~ password generator

Installs htop ~ CLI process viewer

Installs powertop ~ CLI power consumption viewer

Installs iotop ~ CLI I/O usage

Installs ca-certificates ~ HTTPS/SSL/TLS

Installs testssl ~ Testing TLS/SSL encryption

Installs UACScript ~ UAC Bypass for Windows 7

Installs axel ~ CLI download manager

Installs html2text ~ CLI html rendering

Installs tmux2html ~ Render tmux as HTML

Installs gparted ~ GUI partition manager

Installs daemonfs ~ GUI file monitor

Installs p7zip ~ CLI file extractor

Installs zip & unzip ~ CLI file extractors

Installs file roller ~ GUI file extractor

Installs VPN support

Installs hashid ~ identify hash types

Installs httprint ~ GUI web server fingerprint

Installs lbd ~ load balancing detector

Installs wafw00f ~ WAF detector

Installs aircrack-ng ~ Wi-Fi cracking suite

Installs vulscan script for nmap ~ vulnerability scanner add-on

Installs unicornscan ~ fast port scanner

Installs onetwopunch ~ unicornscan & nmap wrapper

Installs Gnmap-Parser ~ Parse Nmap exports into various plain-text formats

Installs udp-proto-scanner ~ common UDP port scanner

Installs clusterd ~ clustered attack toolkit (JBoss, ColdFusion, WebLogic, Tomcat etc)

Installs webhandler ~ shell TTY handler

Installs azazel ~ Linux userland rootkit

Installs Babadook ~ connection-less powershell backdoor

Installs pupy ~ Remote Administration Tool

Installs gobuster ~ Directory/File/DNS busting tool

Installs reGeorg ~ pivot via web shells

Installs b374k ~ (PHP) web shell

Installs adminer ~ Database management in a single PHP file

Installs WeBaCoo ~ Web backdoor cookie

Installs cmdsql ~ (ASPX) web shell

Installs JSP file browser ~ (JSP) web shell

Installs htshells ~ (htdocs/apache) web shells

Installs python-pty-shells ~ PTY shells

Installs bridge-utils ~ Bridge network interfaces

Installs proxychains-ng ~ Proxifier

Installs httptunnel ~ Tunnels data streams in HTTP requests

Installs sshuttle ~ VPN over SSH

Installs pfi ~ Port Forwarding Interceptor

Installs icmpsh ~ Reverse ICMP shell

Installs dnsftp ~ Transfer files over DNS

Installs iodine ~ DNS tunnelling (IP over DNS)

Installs dns2tcp ~ DNS tunnelling (TCP over DNS)

Installs ptunnel ~ ICMP tunnelling

Installs stunnel ~ SSL wrapper

Installs gcc & multilib ~ compiling libraries

Installs MinGW ~ Cross compiling suite

Installs WINE ~ run Windows programs on *nix

Installs MinGW (Windows) ~ cross compiling suite

Installs MinGW (Windows) ~ cross compiling suite

Downloading AccessChk.exe ~ Windows environment tester

Downloading PsExec.exe ~ Pass The Hash 'phun'

Installs Python for Windows via WINE

Installs veil framework ~ bypassing anti-virus

Installs OP packers ~ bypassing anti-virus

Installs hyperion ~ bypassing anti-virus

Installs shellter ~ dynamic shellcode injector

Installs the backdoor factory ~ bypassing anti-virus

Installs Backdoor Factory Proxy (BDFProxy) ~ patches binaries files during a MITM

Installs BetterCap ~ MITM framework

Installs mitmf ~ framework for MITM attacks

Installs responder ~ rogue server

Installs seclist ~ multiple types of (word)lists (and similar things)

Update wordlists ~ collection of wordlists

Installs apt-file ~ which package includes a specific file

Installs apt-show-versions ~ which package version in repo

Installs Babel scripts ~ post exploitation scripts

Installs checksec ~ check *nix OS for security features

Installs shellconv ~ shellcode disassembler

Installs dhex ~ CLI hex compare

Installs lnav ~ CLI log veiwer

Installs commix ~ automatic command injection

Installs fimap ~ automatic LFI/RFI tool

Installs smbmap ~ SMB enumeration tool

Installs smbspider ~ search network shares

Installs CrackMapExec ~ Swiss army knife for Windows environments

Installs credcrack ~ credential harvester via Samba

Installs Empire ~ PowerShell post-exploitation

Installs wig  ~ web application detection

Installs CMSmap ~ CMS detection

Installs droopescan ~ Drupal vulnerability scanner

Installs patator ~ brute force

Installs crowbar ~ brute force

Installs xprobe ~ OS fingerprinting

Installs p0f ~ OS fingerprinting

Installs nbtscan ~ netbios scanne

Setup tftp client & server ~ file transfer methods

Installs Pure-FTPd ~ FTP server/file transfer method (Commented out)

Installs samba ~ file transfer method (Commented out)

Installs apache2 & php ~ web server (Commented out)

Installs mysql ~ database (Commented out)

Installs rsh-client ~ remote shell connections

Installs sshpass ~ automating SSH connections

Installs DBeaver ~ GUI DB manager

Installs ashttp ~ terminal via the web

Installs gotty ~ terminal via the web

Installs guake ~ dropdown terminal

Installs tools for creating a contained testing environment 

Setups SSH

# Performs post-Installs cleanup operations
