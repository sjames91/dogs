function love.conf(t)
    t.console = true
    -- Window size will be set dynamically in main.lua based on grid size
    -- But we can set a default or minimum size here
    t.window.width = 1536   -- 24 * 64 (matches your game grid)
    t.window.height = 1024  -- 16 * 64 (matches your game grid)
    t.window.resizable = false
    t.window.vsync = true
    
    -- Optional: Set window title here instead of in main.lua
    t.window.title = "warmup: snake rider - calaway-2024-game-21"
end