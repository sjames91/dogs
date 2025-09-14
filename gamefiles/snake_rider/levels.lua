-- Level/Map Configuration
local levels = {}

levels.level1 = {
    gridWidth = 24,
    gridHeight = 16,
    theme = "grass",
    appleSpawnRate = 1.5,
    goldAppleSpawnRate = 20,
    timeLimit = 100
}

levels.level2 = {
    gridWidth = 32,
    gridHeight = 24,
    theme = "desert", 
    appleSpawnRate = 1.2,
    goldAppleSpawnRate = 15,
    timeLimit = 120
}

levels.level3 = {
    gridWidth = 16,
    gridHeight = 12,
    theme = "ice",
    appleSpawnRate = 2.0,
    goldAppleSpawnRate = 25,
    timeLimit = 80
}

function levels.loadLevel(levelName)
    local level = levels[levelName]
    if not level then
        error("Level not found: " .. levelName)
    end
    return level
end

return levels