# disable power save features
setterm -blank 0 -powersave off

# modify my PATH and such
. $HOME/.profile

# startup the window manager
exec i3
