function love.conf(t)
	t.identity = "SomeKindaShmup"
	t.appendidentity = true
	t.version = "11.3"
	
	t.console = true
	
	t.window.title = "Some Kinda Shmup"
	t.window.width = 800
	t.window.height = 600
	t.window.borderless = false
	t.window.resizable = false
	t.window.vsync = 0
end