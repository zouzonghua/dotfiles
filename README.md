# dotfiles

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/zouzonghua/dotfiles/blob/main/LICENSE)

my personal dotfiles mac

![shreenshot](./screenshot/202110152200.png)

## installation

```sh
sh <(curl -L https://github.com/zouzonghua/dotfiles/raw/main/install.sh)
```

## vimium

### emacs key mappings

```sh
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

unmapAll

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigating the page
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map n scrollDown
map p scrollUp
map b scrollToLeft
map f scrollToRight
map <a-√> scrollPageUp " <a-v>
map <c-v> scrollPageDown
map <a-¯> scrollToTop " <a-<>
map <a-˘> scrollToBottom " <a->>
map <c-x><c-f> LinkHints.activateMode
map <c-x><c-F> LinkHints.activateModeToOpenInNewForegroundTab
map <c-g>i focusInput
map r reload

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Using the vomnibar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <c-g>o Vomnibar.activate
map <c-g>O Vomnibar.activateInNewTab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Using find
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <c-s> enterFindMode
map <c-S> performFind
map <c-R> performBackwardsFind

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigating history
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <c-_> goBack
map <c-g><c-_> goForward

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Manipulating tabs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <c-x><c-c> removeTab
map <c-x>0 removeTab
map <c-x>1 closeOtherTabs
map <c-f> nextTab
map <c-b> previousTab
map <c-g>pp closeTabsOnLeft
map <c-g>nn closeTabsOnRight
map << moveTabLeft
map >> moveTabRight

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Miscellaneous
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map ? showHelp

```

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
"" Search-Engines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia
b: https://www.baidu.com/s?wd=%s Baidu
g: https://github.com/search?q=%s Github
y: https://www.youtube.com/results?search_query=%s Youtube
ten: https://translate.google.com/?source=osdd#auto|en|%s Google Translator
tcn: https://translate.google.com/?source=osdd#auto|zh-CN|%s Google Translator
ttw: https://translate.google.com/?source=osdd#auto|zh-TW|%s Google Translator

```
