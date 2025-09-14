-- Game Configuration Constants
local config = {}

-- Debug Settings
config.DEBUG_MODE = false  -- Set to true to show debug information

-- Display Settings
config.CELL_SIZE = 64
config.DEFAULT_GRID_WIDTH = 24   -- Default/fallback grid size
config.DEFAULT_GRID_HEIGHT = 16  -- Default/fallback grid size
config.GAME_TITLE = "warmup: snake rider - calaway-2024-game-21"

-- Asset Paths
config.SPRITE_FILES = {
    CHARACTERS = "sprites.json",        -- Character sprites  
    UI = "ui_sprites.json",            -- UI elements
    EFFECTS = "effects_sprites.json"   -- Particle effects
}

-- Main sprite sheet path (for icon and other needs)
config.MAIN_SPRITE_PATH = "assets/characters_sprites/characterspritesheet1.png"

-- Icon Settings
config.ICON = {
    SIZE = 16,           -- Icon dimensions
    SPRITE_X = 0,        -- X position in sprite sheet
    SPRITE_Y = 16,       -- Y position in sprite sheet  
    SPRITE_WIDTH = 16,   -- Width in sprite sheet
    SPRITE_HEIGHT = 16   -- Height in sprite sheet
}


-- Game Settings
config.GAME_DURATION = 100 -- seconds
config.BOOST_DURATION = 11.0 -- speed boost duration in seconds

-- Timer Settings
config.TIMERS = {
    SNAKE_MOVE_NORMAL = 0.15,
    SNAKE_MOVE_BOOST = 0.075,
    APPLE_SPAWN_NORMAL = 1.5,
    APPLE_SPAWN_BOOST = 0.75,
    GOLD_APPLE_SPAWN = 20,
    FLASH_INTERVAL = 0.1,
    PARTICLE_LIFETIME = 0.3
}

-- Apple Settings  
config.MAX_APPLES = 10              -- max apples on screen
config.APPLE_LIFETIME_MIN = 5       -- min apple lifetime
config.APPLE_LIFETIME_MAX = 15      -- max apple lifetime
config.GOLD_APPLE_LIFETIME_MIN = 8  -- min gold apple lifetime
config.GOLD_APPLE_LIFETIME_MAX = 12 -- max gold apple lifetime

-- Score Settings
config.POINTS_PER_APPLE = 10
config.GOLD_APPLE_VALUE = 10 -- worth 10 regular apples
config.FINAL_SCORE_DISPLAY_TIME = 5

-- Visual Effects
config.PARTICLE_COUNT = 12
config.PARTICLE_SPEED_MIN = 100
config.PARTICLE_SPEED_MAX = 200

-- Colors (RGB values 0-1)
config.COLORS = {
    BACKGROUND = {1.0, 0.8, 0.9}, -- Pink
    WHITE = {1, 1, 1},
    GOLD = {1, 0.84, 0},
    YELLOW = {1, 1, 0}
}

return config