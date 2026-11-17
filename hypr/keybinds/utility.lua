----------------------
---- UTILITY BINDS ----
----------------------

hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus --new-window"))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("qyractl screenshot region"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("qyractl screenshot window"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("qyractl screenshot clipboard"))

-- Apps
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("kitty -e btop"))
