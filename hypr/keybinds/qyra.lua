-------------------
---- QYRA BINDS ----
-------------------

-- Shell launcher & settings
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("qyractl launcher toggle"))
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("qyractl settings toggle"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("qyractl powermenu toggle"))

-- Schema-driven toggles & cycling
hl.bind("SUPER + B", hl.dsp.exec_cmd("qyractl config toggle bar.visible"))
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("qyractl config cycle bar.mode"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("qyractl config toggle hypr.blurEnabled"))

-- Quick theme cycling
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("qyractl theme open"))
