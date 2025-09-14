-- UI System - handles all user interface display
local config = require("game_config")

local UI = {}

-- Cached fonts to avoid creating new ones every frame
local fonts = {
    normal = love.graphics.newFont(24),
    large = love.graphics.newFont(96)
}

-- Helper function to draw centered text
local function drawCenteredText(text, font, y)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(text)
    local x = (love.graphics.getWidth() - textWidth) / 2
    love.graphics.print(text, x, y)
end

-- Helper function to calculate grid offset for positioning relative to snake
local function getGridOffsets(gridWidth, gridHeight, cellSize)
    local offsetX = (love.graphics.getWidth() - (gridWidth * cellSize)) / 2
    local offsetY = (love.graphics.getHeight() - (gridHeight * cellSize)) / 2
    return offsetX, offsetY
end

function UI.drawGameplayHUD(score, highScore, timeLeft, snake)
    -- Set normal font for HUD elements
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(config.COLORS.WHITE)
    
    -- Main HUD elements
    love.graphics.print("TIME LEFT: " .. math.ceil(timeLeft), 10, 10)
    love.graphics.print("SCORE: " .. score, 10, 40)
    love.graphics.print("HIGH SCORE: " .. highScore, 10, 70)
    
    -- Speed boost indicator
    if snake.isSpeedBoosted then
        love.graphics.setColor(config.COLORS.YELLOW)
        love.graphics.print("SPEED BOOST: " .. string.format("%.1f", snake.speedBoostTimer), 10, 100)
        love.graphics.setColor(config.COLORS.WHITE)  -- Reset to white
    end
end

function UI.drawStartScreen(gridWidth, gridHeight, cellSize)
    love.graphics.setColor(config.COLORS.WHITE)
    
    -- Calculate position above snake's initial position
    local offsetX, offsetY = getGridOffsets(gridWidth, gridHeight, cellSize)
    local snakeY = (8-1) * cellSize + offsetY  -- Snake's first segment Y position
    local textY = snakeY - (4 * cellSize) - 16  -- 4 cells higher + 16 pixels above snake
    
    drawCenteredText("PRESS UP TO START", fonts.large, textY)
end

function UI.drawFinalScore(finalScore, isNewHighScore)
    love.graphics.setColor(config.COLORS.WHITE)
    
    local text
    if isNewHighScore then
        text = "NEW HIGH SCORE " .. finalScore
    else
        text = "FINAL SCORE " .. finalScore
    end
    
    -- Center on screen
    local y = (love.graphics.getHeight() - fonts.large:getHeight()) / 2
    drawCenteredText(text, fonts.large, y)
end

function UI.drawParticles(particles)
    for _, particle in ipairs(particles) do
        local alpha = particle.timer / particle.maxTimer  -- Fade out over time
        love.graphics.setColor(config.COLORS.GOLD[1], config.COLORS.GOLD[2], config.COLORS.GOLD[3], alpha)
        love.graphics.circle("fill", particle.x, particle.y, 3)  -- Small 3-pixel circles
    end
    
    love.graphics.setColor(config.COLORS.WHITE)  -- Reset color
end

-- Optional: Debug information (can be enabled/disabled)
function UI.drawDebugInfo(snake, apples, gameState)
    if not config.DEBUG_MODE then return end  -- Only show if debug mode is enabled
    
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(1, 1, 0, 0.7)  -- Semi-transparent yellow
    
    local debugY = love.graphics.getHeight() - 120
    love.graphics.print("DEBUG INFO:", 10, debugY)
    love.graphics.print("Snake Length: " .. snake:getLength(), 10, debugY + 20)
    love.graphics.print("Apples: " .. #apples, 10, debugY + 40)
    love.graphics.print("Game State: " .. gameState, 10, debugY + 60)
    love.graphics.print("Direction: " .. snake:getCurrentDirection(), 10, debugY + 80)
    
    love.graphics.setColor(config.COLORS.WHITE)  -- Reset color
end

-- Initialize UI system (call once at startup)
function UI.init()
    -- Cache fonts to avoid creating them every frame
    fonts.normal = love.graphics.newFont(24)
    fonts.large = love.graphics.newFont(96)
end

return UI