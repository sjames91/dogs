-- Game State Management System
local config = require("game_config")
local SaveSystem = require("save_system")

local GameState = {}

-- State enumeration
GameState.STATES = {
    WAITING = "waiting",
    PLAYING = "playing", 
    SHOWING_SCORE = "showingScore"
}

-- Internal state
local currentState = GameState.STATES.WAITING
local stateData = {
    time = 0,
    countdownTime = config.GAME_DURATION,
    score = 0,
    applesEaten = 0,
    finalScore = 0,
    finalScoreTimer = 0,
    isNewHighScore = false,
    highScore = 0
}

-- Initialize game state system
function GameState.init()
    currentState = GameState.STATES.WAITING
    stateData.time = 0
    stateData.countdownTime = config.GAME_DURATION
    stateData.score = 0
    stateData.applesEaten = 0
    stateData.finalScore = 0
    stateData.finalScoreTimer = 0
    stateData.isNewHighScore = false
    stateData.highScore = SaveSystem.getTopScore()
end

-- Get current state
function GameState.getCurrentState()
    return currentState
end

-- Check if in specific state
function GameState.isState(state)
    return currentState == state
end

-- Get state data
function GameState.getData()
    return stateData
end

-- Transition to waiting state
function GameState.transitionToWaiting()
    currentState = GameState.STATES.WAITING
    stateData.time = 0
    stateData.countdownTime = config.GAME_DURATION
    stateData.score = 0
    stateData.applesEaten = 0
end

-- Transition to playing state
function GameState.transitionToPlaying()
    currentState = GameState.STATES.PLAYING
    stateData.time = 0
    stateData.countdownTime = config.GAME_DURATION
end

-- Transition to score display state
function GameState.transitionToScoreDisplay(finalScore)
    currentState = GameState.STATES.SHOWING_SCORE
    stateData.finalScore = finalScore
    stateData.finalScoreTimer = config.FINAL_SCORE_DISPLAY_TIME
    
    -- Check if it's a high score and save it
    local rank = SaveSystem.addHighScore(finalScore, "PLAYER")
    stateData.isNewHighScore = (rank == 1) -- Only show "NEW HIGH SCORE" for #1 spot
    stateData.highScore = SaveSystem.getTopScore() -- Update current high score display
end

-- Update state (returns true if state should continue processing)
function GameState.update(dt)
    -- Handle score display countdown
    if currentState == GameState.STATES.SHOWING_SCORE then
        stateData.finalScoreTimer = stateData.finalScoreTimer - dt
        if stateData.finalScoreTimer <= 0 then
            GameState.transitionToWaiting()
        end
        return false -- Don't process game logic during score display
    end
    
    -- Only update game time when playing
    if currentState == GameState.STATES.PLAYING then
        stateData.time = stateData.time + dt
        stateData.countdownTime = stateData.countdownTime - dt
        
        -- Check for game end
        if stateData.countdownTime <= 0 then
            GameState.transitionToScoreDisplay(stateData.score)
            return false
        end
    end
    
    return currentState == GameState.STATES.PLAYING
end

-- Update score
function GameState.updateScore(applesEaten, snakeLength)
    stateData.applesEaten = applesEaten
    stateData.score = 10 * applesEaten * snakeLength
end

-- Add apples eaten
function GameState.addApplesEaten(count)
    stateData.applesEaten = stateData.applesEaten + count
end

-- Get specific state values (convenience functions)
function GameState.getScore()
    return stateData.score
end

function GameState.getTimeLeft()
    return stateData.countdownTime
end

function GameState.getApplesEaten()
    return stateData.applesEaten
end

function GameState.getFinalScore()
    return stateData.finalScore
end

function GameState.isNewHighScore()
    return stateData.isNewHighScore
end

function GameState.getHighScore()
    return stateData.highScore
end

return GameState