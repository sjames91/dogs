-- Save System - handles high scores only
local SaveSystem = {}

-- Default high scores
local defaultHighScores = {
    {name = "AAA", score = 1000},
    {name = "BBB", score = 800},
    {name = "CCC", score = 600},
    {name = "DDD", score = 400},
    {name = "EEE", score = 200},
}

-- File path
local SAVE_FILE = "highscores.lua"

-- Current high scores
local highScores = {}

-- Simple table serialization
local function serializeTable(t)
    local result = "{\n"
    for i, item in ipairs(t) do
        result = result .. string.format('  {name = "%s", score = %d},\n', item.name, item.score)
    end
    result = result .. "}"
    return result
end

-- Simple table deserialization
local function deserializeTable(str)
    local func, err = load("return " .. str)
    if func then
        return func()
    else
        return nil
    end
end

-- Initialize the save system
function SaveSystem.init()
    SaveSystem.load()
end

-- Load high scores from file
function SaveSystem.load()
    local data = love.filesystem.read(SAVE_FILE)
    if data then
        local loaded = deserializeTable(data)
        if loaded then
            highScores = loaded
        else
            print("High scores file corrupted, loading defaults")
            highScores = {}
            for i, score in ipairs(defaultHighScores) do
                highScores[i] = {name = score.name, score = score.score}
            end
        end
    else
        print("No high scores file found, creating defaults")
        highScores = {}
        for i, score in ipairs(defaultHighScores) do
            highScores[i] = {name = score.name, score = score.score}
        end
    end
end

-- Save high scores to file
function SaveSystem.save()
    local serialized = serializeTable(highScores)
    local success = love.filesystem.write(SAVE_FILE, serialized)
    
    if not success then
        print("Failed to save high scores!")
        return false
    end
    
    return true
end

-- Add a new high score (returns rank if it made top 10, nil otherwise)
function SaveSystem.addHighScore(score, playerName)
    playerName = playerName or "PLAYER"
    
    -- Find where to insert
    for i = 1, #highScores do
        if score > highScores[i].score then
            table.insert(highScores, i, {name = playerName, score = score})
            
            -- Keep only top 10
            if #highScores > 10 then
                table.remove(highScores, 11)
            end
            
            SaveSystem.save()
            return i -- Return rank (1-10)
        end
    end
    
    -- If not inserted and we have less than 10 scores
    if #highScores < 10 then
        table.insert(highScores, {name = playerName, score = score})
        SaveSystem.save()
        return #highScores
    end
    
    return nil -- Didn't make top 10
end

-- Get all high scores
function SaveSystem.getHighScores()
    return highScores
end

-- Get the top score (for displaying current high score)
function SaveSystem.getTopScore()
    return highScores[1] and highScores[1].score or 0
end

return SaveSystem