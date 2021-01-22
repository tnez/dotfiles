# disable power save features
xset s off
xsset -dpms

# keyboard layout
setxkbmap -layout us
setxkbmap -option ctrl:swapcaps
setxkbmap -option altwin:swap_alt_win

# faster key repeat and delay
xset r rate 210 40

# modify my PATH and such
. $HOME/.profile
# . $HOME/.secrets

# startup ssh-agent
eval $(ssh-agent)

# startup the window manager
exec i3
