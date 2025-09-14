function love.conf(t)
    t.console = true
    t.window.width = 1536   -- 24 * 64 (matches your game grid)
    t.window.height = 1024  -- 16 * 64 (matches your game grid)
    t.window.resizable = false
    t.window.vsync = true
    t.window.title = "Snake Rider v.0.1"
end