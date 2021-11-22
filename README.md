# Modified from 
  [Hector Nguyen's autossh](https://github.com/hectornguyen/autossh)
  
# Installation

Linux
```bash
sudo wget https://raw.github.com/royalgarter/autossh/master/autossh.sh -O /usr/local/bin/autossh;sudo chmod +x /usr/local/bin/autossh
```

Window Bash
* Download https://raw.github.com/royalgarter/autossh/master/autossh.sh
* Create bat file in any PATH folder (such as c:/window/system32)

```bash
START <Path to your downloaded autossh.sh file> %*
```

# Usage

This usage is as same as `ssh` command but I suggest you use SSH aliases instead of IP, for example

```bash
autossh root@prod-server
```
Or you can enter to interactive mode by just use it without any paramters

```bash
autossh
```
It will ask you to enter SSH Username and SSH IP/Aliases.

Reference to SSH aliases, please take a look to [this guide](https://coderwall.com/p/dou7uw/multiple-aliases-on-every-entry-of-ssh-s-config-file).

