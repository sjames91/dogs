-- Game Configuration Constants
local config = {}

-- Display Settings
config.CELL_SIZE = 64
config.GRID_WIDTH = 24
config.GRID_HEIGHT = 16
config.GAME_TITLE = "warmup: snake rider - calaway-2024-game-21"

-- Asset Paths and Sprite Sheets
config.SPRITE_SHEETS = {
    -- Main character sprite sheet
    CHARACTERS = {
        path = "assets/characters_sprites/characterspritesheet1.png",
        sprites = {
            SNAKE_HEAD_1 = {x = 0, y = 16, w = 16, h = 16},
            SNAKE_HEAD_2 = {x = 1, y = 32, w = 14, h = 16},
            SNAKE_BODY = {x = 1, y = 48, w = 14, h = 16},
            SNAKE_BODY_CORNER = {x = 32, y = 0, w = 15, h = 15},
            RED_APPLE = {x = 15, y = 31, w = 10, h = 15},
            GOLD_APPLE = {x = 15, y = 46, w = 10, h = 15}
        }
    },
    -- Future sprite sheets would go here:
    -- UI = {
    --     path = "assets/ui/ui_sprites.png",
    --     sprites = {
    --         BUTTON = {x = 0, y = 0, w = 32, h = 16},
    --         PANEL = {x = 32, y = 0, w = 64, h = 32}
    --     }
    -- },
    -- EFFECTS = {
    --     path = "assets/effects/particles.png", 
    --     sprites = {
    --         EXPLOSION_1 = {x = 0, y = 0, w = 16, h = 16},
    --         EXPLOSION_2 = {x = 16, y = 0, w = 16, h = 16}
    --     }
    -- }
}

-- Legacy support - keep this for backward compatibility
config.SPRITE_PATH = config.SPRITE_SHEETS.CHARACTERS.path
config.SPRITE_DATA = config.SPRITE_SHEETS.CHARACTERS.sprites

-- Game Settings
config.GAME_DURATION = 100  -- seconds
config.MOVE_SPEED = 0.15    -- normal speed
config.BOOST_SPEED = 0.075  -- speed boost speed
config.BOOST_DURATION = 11.0 -- speed boost duration

-- Apple Settings
config.APPLE_SPAWN_RATE = 1.5      -- normal spawn rate
config.APPLE_SPAWN_RATE_BOOST = 0.75 -- boosted spawn rate
config.GOLD_APPLE_SPAWN_RATE = 20   -- gold apple spawn rate
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
config.PARTICLE_LIFETIME = 0.3
config.PARTICLE_SPEED_MIN = 100
config.PARTICLE_SPEED_MAX = 200
config.FLASH_INTERVAL = 0.1

-- Colors (RGB values 0-1)
config.COLORS = {
    BACKGROUND = {1.0, 0.8, 0.9}, -- Pink
    WHITE = {1, 1, 1},
    GOLD = {1, 0.84, 0},
    YELLOW = {1, 1, 0}
}

return config