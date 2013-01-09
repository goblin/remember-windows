## A script that restores positions of windows

With this, you can save the layout of your windows (i.e. with your external
monitor plugged in), move them around (i.e. when you unplug the monitor,
most WMs will move them to random places on the other monitor), and then
restore them back to where they were (i.e. when you plug the monitor back in).

## Usage

To save the current layout:
```
% wmctrl -G -p -l > /tmp/saved-windows
```

To restore all windows back to where they were:
% ./restore.pl /tmp/saved-windows

## Known Bugs

Window decorations can sometimes confuse the positioner by a few pixels.
The script has hardcoded values for my window decorations for my theme,
so it may vary for yours. See the `sub move_cmd` for details.
You can determine your window decorations by comparing the output of
`wmctrl` before and after the repositioning.

## Tested on

Debian sid with xfce 4.8
