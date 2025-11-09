# dotfiles

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/zouzonghua/dotfiles/blob/main/LICENSE)

![shreenshot](https://raw.githubusercontent.com/zouzonghua/image-hosting/main/img/Screenshot_2023-03-12_11-07-19.png)

## installation

```sh
sh <(curl -L https://github.com/zouzonghua/dotfiles/raw/main/install.sh)
```


## macOS 全局 Emacs 快捷键（极简版）

| 功能             | 快捷键               | 说明 | 类型 |
| ---------------- | ------------------- | ---- | ---- |
| 光标移动到行首   | `Ctrl + a`          | 光标移动到当前行首 | Native |
| 光标移动到行尾   | `Ctrl + e`          | 光标移动到当前行尾 | Native |
| 光标向上移动     | `Ctrl + p`          | 光标移动到上一行 | Native |
| 光标向下移动     | `Ctrl + n`          | 光标移动到下一行 | Native |
| 光标向前移动     | `Ctrl + f`          | 光标向前移动一个字符 | Native |
| 光标向后移动     | `Ctrl + b`          | 光标向后移动一个字符 | Native |
| 删除             | `Delete`            | 使用键盘原生 Delete | Native |
| 撤销             | `Cmd + z`           | 撤销上一步操作 | Native |
| 重做             | `Cmd + Shift + z`   | 重做上一步操作 | Native |
| 复制             | `Cmd + c`           | 系统原生命令 | Native |
| 粘贴             | `Cmd + v`           | 系统原生命令 | Native |
| 向前一个单词     | `Option + f`        | 光标向前移动一个单词 | Hack |
| 向后一个单词     | `Option + b`        | 光标向后移动一个单词 | Hack |
| 向前选择一个单词 | `Option + Shift + f`| 选中光标所在位置到下一个单词 | Hack |
| 向后选择一个单词 | `Option + Shift + b`| 选中光标所在位置到前一个单词 | Hack |
| 选择上一行       | `Ctrl + Shift + P`  | 光标向上选中一行 | Hack |
| 选择下一行       | `Ctrl + Shift + N`  | 光标向下选中一行 | Hack |
| Page Down        | `Ctrl + v`          | 向下翻页一屏 | Hack |
| Page Up          | `Option + v`        | 向上翻页一屏 | Hack |
| Escape           | `Ctrl + g`          | 退出当前操作或取消选中状态 | Hack |


## vimium

### vim key mappings

```sh
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

unmapAll

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigating the page
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map j scrollDown
map k scrollUp
map <c-d> scrollPageDown
map <c-u> scrollPageUp
map <c-f> scrollFullPageDown
map <c-b> scrollFullPageUp
map G scrollToBottom
map gg scrollToTop
map f LinkHints.activateMode
map F LinkHints.activateModeToOpenInNewTab
map gi focusInput
map yf LinkHints.activateModeToCopyLinkUrl
map yy copyCurrentUrl
map p openCopiedUrlInCurrentTab
map P openCopiedUrlInNewTab
map r reload

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Using the vomnibar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map O Vomnibar.activate
map o Vomnibar.activateInNewTab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Using find
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map / enterFindMode
map n performFind
map N performBackwardsFind

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigating history
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map u goBack
map <c-r> goForward

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Manipulating tabs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <c-h> previousTab
map <c-l> nextTab
map <c-c> removeTab
map ,hh closeTabsOnLeft
map ,ll closeTabsOnRight
map << moveTabLeft
map >> moveTabRight

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Miscellaneous
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map ? showHelp

```

### search engines

```sh
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Search engines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia
b: https://www.baidu.com/s?wd=%s Baidu
g: https://github.com/search?q=%s Github
y: https://www.youtube.com/results?search_query=%s Youtube
ten: https://translate.google.com/?source=osdd#auto|en|%s Google Translator
tcn: https://translate.google.com/?source=osdd#auto|zh-CN|%s Google Translator
ttw: https://translate.google.com/?source=osdd#auto|zh-TW|%s Google Translator

```

## Arch Linux

### 配置网络

连接网络
```sh
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect wifi-name
exit
```

设置密码 使用 ssh 登录
```sh
passwd
```

禁用 reflector 服务
```sh
systemctl stop reflector.service
```

修改软件源
```sh
vim /etc/pacman.d/mirrorlist
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
```

### 分区

```sh
gdisk /dev/sda
```

格式化分区

```sh
Command (? for help):o
```

创建 EFI 分区
```sh
Command (? for help):n
Permission number: 1
First sector     : enter
Last sector      : +512M
Hex code or GUID : EF00
```

创建 SWAP 分区
```sh
Command (? for help):n
Permission number: 2
First sector     : enter
Last sector      : +8G
Hex code or GUID : 8200
```

创建 Root 分区
```sh
Command (? for help):n
Permission number: 3
First sector     : enter
Last sector      : enter
Hex code or GUID : 8300
```

格式化挂载分区
```sh
mkfs.vfat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
```

### 安装系统

安装基础软件包
```sh
pacstrap /mnt base base-devel linux linux-firmware vim dhcpcd iwd intel-ucode
```

生成 fstab 文件
```sh
genfstab -U -p /mnt >> /mnt/etc/fstab
```

切换系统环境
```sh
arch-chroot /mnt
```

配置主机名
```sh
echo thinkpad > /etc/hostname
```

vim /etc/hosts

```sh
127.0.0.1   localhost
::1         localhost
127.0.1.1   thinkpad.localdomain	thinkpad
```

硬件时间设置
```sh
hwclock --systohc
```

配置时区

vi /etc/locale.gen
```sh
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8

```

生成 locale
```sh
locale-gen
```

```sh
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 配置用户

创建用户
```sh
useradd -m -G wheel -s /bin/bash ${USER}
```

设置密码
```sh
passwd ${USER}
```

配置权限

```sh
visudo
Defaults env_keep += “ HOME ”
%wheel ALL=(ALL) ALL
```

### 安装 grub

```sh
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
exit
reboot
```

### 配置网络

开启 dhcp,iwd 服务

```sh
systemctl enable --now dhcpcd
systemctl enable --now iwd
```

vim /etc/dhcpcd.conf

```sh
interface wlan0
static ip_address=192.168.1.6/24
static routers=192.168.1.254
static domain_name_servers=192.168.1.254
```
### 输入法和字体

```sh
sudo pacman -S fcitx5-im fcitx5-rime
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-noto-nerd
```

### 音量管理

```sh
sudo pacman -S alsa-utils pulseaudio pavucontrol
```

## Debian

### 初始化设置

为了提升系统的安全性和可靠性，我们可以进行基础的系统初始化设置。它们包括：

1. [创建一个普通管理员账户]
2. [使用 SSH 密钥认证身份]
3. [禁用 SSH 密码登录]

#### 一、创建普通管理员账户

##### 1. 创建普通用户

> 实际的用户名请按需修改

```sh
adduser zonghua
```

##### 2. 将用户添加到 sudo 用户组

使用 `usermod` 命令，附加 `-aG` 参数，将用户 `zouzonghua` 添加到 `sudo` 用户组。

```sh
usermod -aG sudo zouzonghua
```

> `-aG` 参数可以在保持用户原有用户组设置的前提下，将用户追加到指定的用户组。不使用 `-a` 参数会使用户离开原有用户组，仅加入到命令中指定的用户组。

#### 二、使用 SSH 密钥登录云服务器

##### 1. 创建密钥对

###### Windows 系统

> 在本地计算机的 PowerShell 中执行 ssh-keygen.exe 命令，会在 C:\Users\Herald/.ssh/ 目录生成一个名为 id_rsa 的私钥和一个名为 id_rsa.pub 的公钥。

```sh
ssh-keygen.exe
```

##### MacOS & Linux 系统

> 打开终端，执行 ssh-keygen 命令，会在 ~/.ssh/ 目录生成一个名为 id_rsa 的私钥和一个名为 id_rsa.pub 的公钥。

```sh
ssh-keygen
```

##### 2. 将公钥复制到云服务器

###### 通用方法

> Windows 系统将命令中的 ~/.ssh/id_rsa.pub 替换成 C:\Users\zonghua\.ssh\id_rsa.pub。

username 替换为登录云服务器的用户名，remote_host 替换为云服务器的 IP 地址。

```sh
cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### 三、禁用 SSH 密码登录 & ROOT 账户登录

编辑 ssh 服务的配置文件 `sshd_config` 将 PasswordAuthentication 项修改为 no ，PermitRootLogin 项修改为 no 。

```sh
sudo vi /etc/ssh/sshd_config
```

重启 ssh 服务

```sh
sudo systemctl restart ssh
```

### 安装常用软件


### tpl

```bash
1、sudo apt install tlp tlp-rdw
2、sudo tlp start 开启
3、sudo tlp-stat 查看信息
4、sudo tlp-stat -b 的输出将指导您安装哪个包
5、sudo apt install acpi-call-dkms 内核模块 Linux 内核 5.17 以下需要安装
6、sudo tlp setcharge 20 80 BAT0 配置电池充电阀值
```

#### 蓝牙

```bash
sudo apt-get install pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware blueman
sudo service bluetooth restart
sudo killall pulseaudio
```

#### zsh

查看系统当前的 shell

```sh
echo $SHELL
```

查看系统所有 shell

```sh
cat /etc/shells
```

安装&重启

```sh
sudo apt install zsh -y
chsh -s /bin/zsh
sudo reboot
```

#### pip beancount fava

```bash
sudo apt install python3-venv python3-pip  
sudo -H pip3 install --upgrade pip
sudo -H pip3 install --break-system-packages --upgrade pip
sudo -H pip3 install -i https://pypi.mirrors.ustc.edu.cn/simple --break-system-packages --upgrade pip
pip3 install --user beancount fava
pip3 install --user  -i https://pypi.mirrors.ustc.edu.cn/simple --break-system-packages  beancount fava
```
#### xclip xsel
```bash
sudo apt install xclip xsel
```

#### 更新软件源、软件、删除没用到的包

```sh
sudo apt update
sudo apt upgrade
sudo apt autoremove
```

### 常见错误解决

#### Errors were encountered while processing 的解决办法

```sh
cd /var/lib/dpkg
sudo mv info info.bak
sudo mkdir info
sudo apt-get upgrade
```

### 首次使用

```
brew install git-crypt
brew install gpg
gpg --import path/to/public/key/backup/file
gpg --import path/to/secret/key/backup/file
git-crypt unlock
```

### 导入 ssh 配置
```
brew install stow
stow --no-folding --verbose --adopt ssh
```

### 修改 ssh 密钥权限

```
chmod 600 ~/.ssh/id_rsa
ssh -T git@github.com
```

### 转换仓库地址

 ```git remote set-url origin git@github.com:zouzonghua/dotfiles.git```

