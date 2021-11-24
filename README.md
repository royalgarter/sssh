# Screen SSH with auto reconnection

# Modified from [Hector Nguyen's autossh](https://github.com/hectornguyen/autossh)
  
# Installation

Pre-requires screen on your remote server/machine
```bash
sudo apt install screen

sudo yum install screen
```

Linux / MacOS
```bash
sudo wget https://raw.github.com/royalgarter/sssh/master/sssh.sh -O /usr/local/bin/sssh;sudo chmod +x /usr/local/bin/sssh
```

Window Bash
* STEP 1: Download https://raw.github.com/royalgarter/sssh/master/sssh.sh

* STEP 2: Create batch file `sssh.bat` in any %PATH% folder (such as c:/window/system32) with below content
```bash
START <Path to your downloaded sssh.sh file> %*
```

* DONE: Now you can use it as a command-line tool `sssh`


# Usage

* Note: All parameters are fowarded to original `ssh` command.

This usage is as same as `ssh` command but I suggest you use SSH aliases instead of IP, for example

```bash
sssh root@prod-server
```
Or you can enter to interactive mode by just use it without any paramters

```bash
sssh
```
It will ask you to enter SSH Username and SSH IP/Aliases.

Reference to SSH aliases, please take a look to [this guide](https://coderwall.com/p/dou7uw/multiple-aliases-on-every-entry-of-ssh-s-config-file).

