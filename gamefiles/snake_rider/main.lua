
local config = require("game_config")
local SpriteManager = require("sprite_manager")
local SaveSystem = require("save_system")
local Snake = require("snake")
local UI = require("ui")
local EnvironmentalSpawns = require("environmental_spawns")
local GameState = require("game_state")
local Effects = require("effects")
local CollisionSystem = require("collision_system")
local sprites
local snake
function love.load() 
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    SaveSystem.init()
    sprites = SpriteManager.registerFromJSON("CHARACTERS", config.SPRITE_FILES.CHARACTERS)
    cellSize = config.CELL_SIZE
    gridWidth = config.DEFAULT_GRID_WIDTH    -- Game grid dimensions
    gridHeight = config.DEFAULT_GRID_HEIGHT

    -- Set window icon from sprite sheet
    local iconImageData = love.image.newImageData(config.ICON.SIZE, config.ICON.SIZE)
    local spritesheet = love.image.newImageData(config.MAIN_SPRITE_PATH)
    iconImageData:paste(spritesheet, 0, 0, config.ICON.SPRITE_X, config.ICON.SPRITE_Y, config.ICON.SPRITE_WIDTH, config.ICON.SPRITE_HEIGHT)
    love.window.setIcon(iconImageData)

    -- Initialize systems
    GameState.init()
    Effects.init()
    EnvironmentalSpawns.init()
    
    -- Initialize snake
    snake = Snake.new(12, 8, 'up')
    apples = {}  -- Array to hold multiple apples
    
    -- Don't spawn initial apple - wait for space press
end-- Helper function to calculate screen offsets for centering the grid
local function getGridOffsets()
    local offsetX = (love.graphics.getWidth() - (gridWidth * cellSize)) / 2
    local offsetY = (love.graphics.getHeight() - (gridHeight * cellSize)) / 2
    return offsetX, offsetY
end

function love.update(dt)
    -- Update game state (handles state transitions and timing)  
    local shouldProcessGame = GameState.update(dt)
    local stateData = GameState.getData()
    
    -- Reset game when transitioning back to waiting (check if we just transitioned)
    if GameState.isState(GameState.STATES.WAITING) and stateData.time == 0 and stateData.finalScoreTimer <= 0 then
        snake:reset(12, 8, 'up')
        apples = {}
        EnvironmentalSpawns.resetTimers()
        Effects.reset()
    end
    
    -- Only process game logic when playing
    if not shouldProcessGame then
        return
    end
    
    -- Update environmental spawns (handles item lifetimes and automatic spawning)
    EnvironmentalSpawns.update(dt, snake, apples, gridWidth, gridHeight)
    
    -- Update snake
    snake:update(dt, gridWidth, gridHeight)

    -- Update effects
    Effects.update(dt)

    -- Handle collisions and scoring
    local offsetX, offsetY = getGridOffsets()
    CollisionSystem.update(snake, apples, offsetX, offsetY, cellSize)
end


-- Key Pressed Function

function love.keypressed(key, scancode)

    if scancode == "s" then key = "down"
        elseif scancode == "w" then key = "up"
        elseif scancode == "d" then key = "right"
        elseif scancode == "a" then key = "left"    
    end

    if key == "escape" then
        love.event.quit()
    end
    
    if key == "up" and GameState.isState(GameState.STATES.WAITING) then
        GameState.transitionToPlaying()
        snake:addDirection('up')  -- Set initial direction to up
        EnvironmentalSpawns.spawnApple(snake, apples, gridWidth, gridHeight)  -- Spawn first apple when game starts
        return
    end
    
    if not GameState.isState(GameState.STATES.PLAYING) then
        return
    end

    -- Use Snake module's addDirection method
    if key == "right" then
        snake:addDirection('right')
    elseif key == 'left' then
        snake:addDirection('left')
    elseif key == 'up' then
        snake:addDirection('up')
    elseif key == 'down' then
        snake:addDirection('down')
    end
end

function love.draw()
    -- Set background color and fill the screen
    love.graphics.setColor(1.0, 0.8, 0.9)  -- Pink background
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)  -- Reset to white for other drawing
    local offsetX, offsetY = getGridOffsets()
    
    -- Draw snake using Snake module
    snake:draw(sprites, offsetX, offsetY, cellSize, gridWidth, gridHeight)
    
    -- Reset color to white before drawing UI and other elements
    love.graphics.setColor(1, 1, 1)

    -- Draw items using environmental spawns renderer
    EnvironmentalSpawns.drawItems(apples, sprites, offsetX, offsetY, cellSize)

    -- Set larger font for text
    love.graphics.setFont(love.graphics.newFont(24))
    
    if GameState.isState(GameState.STATES.SHOWING_SCORE) then
        -- Show final score or new high score in center of screen
        love.graphics.setFont(love.graphics.newFont(96))  -- 4x larger than normal text
        UI.drawFinalScore(GameState.getFinalScore(), GameState.isNewHighScore())
    elseif GameState.isState(GameState.STATES.WAITING) then
        -- Show "Press Space to Start" above snake's initial position
        UI.drawStartScreen(gridWidth, gridHeight, cellSize)
    else
        -- Normal gameplay UI
        UI.drawGameplayHUD(GameState.getScore(), GameState.getHighScore(), GameState.getTimeLeft(), snake)
    end

    -- Reset color to white for other drawing
    love.graphics.setColor(1, 1, 1)

    -- Draw particles
    UI.drawParticles(Effects.getParticles())
    
    love.graphics.setColor(1, 1, 1)  -- Reset color
end