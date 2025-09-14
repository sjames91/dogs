-- Environmental Spawning System - handles spawning of all game items
local config = require("game_config")

local EnvironmentalSpawns = {}

-- Spawn Manager State
local spawnTimers = {
    apple = 0,
    goldApple = 0
}

-- Item type definitions
local ItemTypes = {
    APPLE = {
        sprite = "RED_APPLE",
        gold = false,
        lifetime_min = config.APPLE_LIFETIME_MIN,
        lifetime_max = config.APPLE_LIFETIME_MAX,
        value = 1
    },
    GOLD_APPLE = {
        sprite = "GOLD_APPLE", 
        gold = true,
        lifetime_min = config.GOLD_APPLE_LIFETIME_MIN,
        lifetime_max = config.GOLD_APPLE_LIFETIME_MAX,
        value = 10
    }
    -- Future items can be added here:
    -- POWER_UP = { sprite = "POWER_UP", special = true, ... },
    -- OBSTACLE = { sprite = "ROCK", solid = true, ... }
}

-- Generic function to find valid spawn positions
local function getAvailablePositions(snake, existingItems, gridWidth, gridHeight)
    local available = {}
    local occupied = {}
    
    -- Mark snake segments as occupied
    for _, segment in ipairs(snake.segments) do
        occupied[segment.x .. ',' .. segment.y] = true
    end
    
    -- Mark existing item positions as occupied
    for _, item in ipairs(existingItems) do
        occupied[item.x .. ',' .. item.y] = true
    end
    
    -- Collect all unoccupied positions
    for x = 1, gridWidth do
        for y = 1, gridHeight do
            if not occupied[x .. ',' .. y] then
                table.insert(available, {x = x, y = y})
            end
        end
    end
    
    return available
end

-- Generic spawning function
function EnvironmentalSpawns.spawnItem(itemType, snake, existingItems, gridWidth, gridHeight)
    local itemDef = ItemTypes[itemType]
    if not itemDef then
        error("Unknown item type: " .. itemType)
    end
    
    local available = getAvailablePositions(snake, existingItems, gridWidth, gridHeight)
    
    if #available > 0 then
        local position = available[love.math.random(1, #available)]
        local lifetime = love.math.random(itemDef.lifetime_min, itemDef.lifetime_max)
        
        local newItem = {
            x = position.x,
            y = position.y,
            timer = lifetime,
            gold = itemDef.gold or false,
            sprite = itemDef.sprite,
            value = itemDef.value,
            itemType = itemType
        }
        
        table.insert(existingItems, newItem)
        return newItem
    end
    
    return nil  -- No space available
end

-- Convenience functions for specific items
function EnvironmentalSpawns.spawnApple(snake, apples, gridWidth, gridHeight)
    return EnvironmentalSpawns.spawnItem("APPLE", snake, apples, gridWidth, gridHeight)
end

function EnvironmentalSpawns.spawnGoldApple(snake, apples, gridWidth, gridHeight)
    return EnvironmentalSpawns.spawnItem("GOLD_APPLE", snake, apples, gridWidth, gridHeight)
end

-- Check if a specific item type already exists
function EnvironmentalSpawns.hasItemType(items, itemType)
    for _, item in ipairs(items) do
        if item.itemType == itemType or (itemType == "GOLD_APPLE" and item.gold) then
            return true
        end
    end
    return false
end

-- Get spawn rate for an item type based on game state
function EnvironmentalSpawns.getSpawnRate(itemType, isSpeedBoosted)
    if itemType == "APPLE" then
        return isSpeedBoosted and config.TIMERS.APPLE_SPAWN_BOOST or config.TIMERS.APPLE_SPAWN_NORMAL
    elseif itemType == "GOLD_APPLE" then
        return config.TIMERS.GOLD_APPLE_SPAWN
    end
    
    -- Default spawn rate for unknown items
    return 5.0
end

-- Future: Spawn multiple items at once for complex levels
function EnvironmentalSpawns.spawnWave(waveConfig, snake, existingItems, gridWidth, gridHeight)
    local spawnedItems = {}
    
    for itemType, count in pairs(waveConfig) do
        for i = 1, count do
            local item = EnvironmentalSpawns.spawnItem(itemType, snake, existingItems, gridWidth, gridHeight)
            if item then
                table.insert(spawnedItems, item)
            end
        end
    end
    
    return spawnedItems
end

-- Get item type definition (useful for UI or game logic)
function EnvironmentalSpawns.getItemDefinition(itemType)
    return ItemTypes[itemType]
end

-- Add new item types dynamically (for mods or level-specific items)
function EnvironmentalSpawns.registerItemType(itemType, definition)
    ItemTypes[itemType] = definition
end

-- Render all items
function EnvironmentalSpawns.drawItems(items, sprites, offsetX, offsetY, cellSize)
    -- Preserve aspect ratio for apple sprites
    local qw, qh = 10, 15
    local margin = 1
    local scale = math.min((cellSize - margin) / qw, (cellSize - margin) / qh)

    for _, item in ipairs(items) do
        -- Use gold sprite for gold apples, red sprite for regular apples
        local spriteName = item.gold and "GOLD_APPLE" or "RED_APPLE"
        sprites:draw(
            spriteName,
            (item.x-1) * cellSize + offsetX + cellSize/2,
            (item.y-1) * cellSize + offsetY + cellSize/2,
            0,
            scale, scale,
            qw/2, qh/2
        )
    end
end

-- Initialize spawn manager
function EnvironmentalSpawns.init()
    spawnTimers.apple = 0
    spawnTimers.goldApple = 0
end

-- Reset all spawn timers (called on game reset)
function EnvironmentalSpawns.resetTimers()
    spawnTimers.apple = 0
    spawnTimers.goldApple = 0
end

-- Update all spawn timers and handle automatic spawning
function EnvironmentalSpawns.update(dt, snake, items, gridWidth, gridHeight)
    -- Update item lifetimes and remove expired items
    for i = #items, 1, -1 do
        items[i].timer = items[i].timer - dt
        if items[i].timer <= 0 then
            table.remove(items, i)
        end
    end
    
    -- Update spawn timers
    spawnTimers.apple = spawnTimers.apple + dt
    spawnTimers.goldApple = spawnTimers.goldApple + dt
    
    -- Handle apple spawning
    local appleSpawnRate = EnvironmentalSpawns.getSpawnRate("APPLE", snake.isSpeedBoosted)
    if spawnTimers.apple >= appleSpawnRate and #items < 10 then  -- Limit to 10 items on screen
        spawnTimers.apple = 0
        EnvironmentalSpawns.spawnApple(snake, items, gridWidth, gridHeight)
    end
    
    -- Handle gold apple spawning (only if no gold apple exists)
    if spawnTimers.goldApple >= EnvironmentalSpawns.getSpawnRate("GOLD_APPLE", false) then
        spawnTimers.goldApple = 0
        if not EnvironmentalSpawns.hasItemType(items, "GOLD_APPLE") then
            EnvironmentalSpawns.spawnGoldApple(snake, items, gridWidth, gridHeight)
        end
    end
end

return EnvironmentalSpawns