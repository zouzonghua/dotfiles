# dotfiles

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/zouzonghua/dotfiles/blob/macos/LICENSE)

## 首次使用

```
brew install git-crypt
brew install gpg
gpg --import path/public/file
gpg --import path/secret/file
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

 ```
 git remote set-url origin git@github.com:zouzonghua/dotfiles.git
```
