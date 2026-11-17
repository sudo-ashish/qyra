-------------------------
---- MULTIMEDIA BINDS ----
-------------------------

-- Volume (Quickshell OSD via qyractl)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("qyractl osd outputVolume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("qyractl osd outputVolume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("qyractl osd outputVolume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("qyractl osd inputVolume mute-toggle"), { locked = true })

-- Fine Volume Adjustments (1%)
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("qyractl osd outputVolume raise-fine"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("qyractl osd outputVolume lower-fine"), { locked = true, repeating = true })

-- Brightness (Quickshell OSD via qyractl)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qyractl brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qyractl brightness lower"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessUp", hl.dsp.exec_cmd("qyractl brightness raise-fine"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd("qyractl brightness lower-fine"), { locked = true, repeating = true })

-- Media Control
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
