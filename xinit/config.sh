# disable power save features
setterm -blank 0 -powersave off

# faster key repeat and delay
xset r rate 210 40

# modify my PATH and such
. $HOME/.profile

# startup the window manager
exec i3
