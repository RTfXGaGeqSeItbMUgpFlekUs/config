#!/bin/sh

xcompmgr -c -t-7.5 -l-7.5 -r5 -o.5 &
if [ `hostname` = 'book' ]; then
	feh --bg-center Media/Pictures/Backgrounds/Striped\ Backgrounds/Striped\ Blue/Striped\ Blue\ 1440x900.jpg
elif [ `hostname` = 'desk' ]; then
	feh --bg-center Media/Pictures/Backgrounds/Striped\ Backgrounds/Striped\ Blue/Striped\ Blue\ 1680x1050.jpg
fi

tint2 &

setxkbmap us altgr-intl
dbus-daemon --session &

#exec ck-launch-session openbox
exec openbox
