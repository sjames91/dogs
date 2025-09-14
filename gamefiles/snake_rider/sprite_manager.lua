-- Sprite Manager - handles all sprite loading and management
local SpriteManager = {}

-- Initialize with sprite sheet data
function SpriteManager:new(spriteSheetPath, spriteData)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    
    obj.spriteSheet = love.graphics.newImage(spriteSheetPath)
    obj.quads = {}
    obj.spriteData = spriteData
    obj.sheetPath = spriteSheetPath -- Store for reference
    
    -- Create all quads at initialization
    for name, data in pairs(spriteData) do
        obj.quads[name] = love.graphics.newQuad(
            data.x or (data.col * 16), -- Support both pixel coords and grid coords
            data.y or (data.row * 16),
            data.w, data.h,
            obj.spriteSheet:getWidth(),
            obj.spriteSheet:getHeight()
        )
    end
    
    return obj
end

-- Create a global sprite manager registry
SpriteManager.registry = {}

-- Register a sprite manager with a name
function SpriteManager.register(name, spriteSheetPath, spriteData)
    SpriteManager.registry[name] = SpriteManager:new(spriteSheetPath, spriteData)
    return SpriteManager.registry[name]
end

-- Get a registered sprite manager
function SpriteManager.get(name)
    return SpriteManager.registry[name]
end

-- Draw from any registered sprite manager
function SpriteManager.drawFrom(managerName, spriteName, x, y, rotation, scaleX, scaleY, originX, originY)
    local manager = SpriteManager.registry[managerName]
    if manager then
        manager:draw(spriteName, x, y, rotation, scaleX, scaleY, originX, originY)
    end
end

-- Get a quad by name
function SpriteManager:getQuad(name)
    return self.quads[name]
end

-- Draw a sprite
function SpriteManager:draw(spriteName, x, y, rotation, scaleX, scaleY, originX, originY)
    local quad = self.quads[spriteName]
    if quad then
        love.graphics.draw(self.spriteSheet, quad, x, y, rotation or 0, scaleX or 1, scaleY or 1, originX or 0, originY or 0)
    end
end

-- Batch create sprites for animations (useful for sprite sequences)
function SpriteManager:createAnimation(baseName, startX, startY, frameWidth, frameHeight, frameCount, columns)
    columns = columns or frameCount
    local frames = {}
    
    for i = 0, frameCount - 1 do
        local x = startX + (i % columns) * frameWidth
        local y = startY + math.floor(i / columns) * frameHeight
        local frameName = baseName .. "_" .. (i + 1)
        
        self.quads[frameName] = love.graphics.newQuad(
            x, y, frameWidth, frameHeight,
            self.spriteSheet:getWidth(),
            self.spriteSheet:getHeight()
        )
        table.insert(frames, frameName)
    end
    
    return frames
end

-- Simple JSON parser for basic sprite data
local function parseJSON(jsonString)
    -- Remove whitespace
    jsonString = jsonString:gsub("%s+", "")
    
    -- Simple parser for our specific JSON structure
    local image = jsonString:match('"image":"([^"]+)"')
    local sprites = {}
    
    -- Find the sprites section
    local spritesSection = jsonString:match('"sprites":%{(.-)%}%}$')
    if spritesSection then
        -- Parse each sprite entry
        for name, data in spritesSection:gmatch('"([^"]+)":%{([^}]+)%}') do
            local x = tonumber(data:match('"x":(%d+)'))
            local y = tonumber(data:match('"y":(%d+)'))
            local w = tonumber(data:match('"w":(%d+)'))
            local h = tonumber(data:match('"h":(%d+)'))
            
            if x and y and w and h then
                sprites[name] = {x = x, y = y, w = w, h = h}
            end
        end
    end
    
    return {
        spriteSheet = {
            image = image,
            sprites = sprites
        }
    }
end

-- Load sprite manager from JSON file
function SpriteManager.fromJSON(jsonPath)
    local jsonData = love.filesystem.read(jsonPath)
    if not jsonData then
        error("Could not read JSON file: " .. jsonPath)
    end
    
    local success, data = pcall(parseJSON, jsonData)
    
    if not success then
        error("Could not parse JSON file: " .. jsonPath)
    end
    
    return SpriteManager:new(data.spriteSheet.image, data.spriteSheet.sprites)
end

-- Load and register from JSON
function SpriteManager.registerFromJSON(name, jsonPath)
    SpriteManager.registry[name] = SpriteManager.fromJSON(jsonPath)
    return SpriteManager.registry[name]
end

return SpriteManager