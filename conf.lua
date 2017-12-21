function love.conf(t)
	t.identity = "loveComp"

	t.console = true

	--[[for k,v in pairs{
		"audio", "event", "graphics", "image", "joystick",
		"keyboard", "math", "mouse", "physics", "sound",
		"touch", "video", "window", "thread"
	} do
		t.modules[v] = false
	end]]
	t.window = false
end
