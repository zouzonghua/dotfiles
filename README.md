# dotfiles

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/zouzonghua/dotfiles/blob/main/LICENSE)

![shreenshot](./screenshot/202110152200.png)

## installation

```sh
sh <(curl -L https://github.com/zouzonghua/dotfiles/raw/main/install.sh)
```

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
