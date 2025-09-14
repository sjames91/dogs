-- Snake module - handles snake character and movement logic
local config = require("game_config")
local Snake = {}
Snake.__index = Snake

function Snake.new(x, y, direction)
    local snake = setmetatable({}, Snake)
    
    -- Initialize snake segments (head to tail order)
    snake.segments = {
        {x = x, y = y},
        {x = x, y = y + 1},
        {x = x, y = y + 2}
    }
    
    -- Movement system
    snake.directionQueue = {direction or 'up'}
    snake.moveTimer = 0
    
    -- Speed boost system
    snake.isSpeedBoosted = false
    snake.speedBoostTimer = 0
    
    -- Visual effects (flashing is tied to speed boost)
    snake.isFlashing = false
    
    return snake
end

function Snake:update(dt, gridWidth, gridHeight)
    -- Track if snake moved this frame
    self.movedThisFrame = false
    
    -- Update speed boost and flash timer (they should be synchronized)
    if self.isSpeedBoosted then
        self.speedBoostTimer = self.speedBoostTimer - dt
        if self.speedBoostTimer <= 0 then
            self.isSpeedBoosted = false
            self.speedBoostTimer = 0
            self.isFlashing = false  -- Stop flashing when boost ends
        else
            -- Keep flashing active as long as speed boost is active
            self.isFlashing = true
        end
    else
        -- Ensure flashing is off when not speed boosted
        self.isFlashing = false
    end

    -- Movement timing
    self.moveTimer = self.moveTimer + dt
    local moveSpeed = self.isSpeedBoosted and config.TIMERS.SNAKE_MOVE_BOOST or config.TIMERS.SNAKE_MOVE_NORMAL
    
    if self.moveTimer >= moveSpeed then
        self.moveTimer = 0
        self.movedThisFrame = true
        self:move(gridWidth, gridHeight)
        
        -- Auto-respawn if snake is completely gone
        if self:isEmpty() then
            self:reset(12, 8, 'up')
        end
    end
end

function Snake:move(gridWidth, gridHeight)
    -- Only move if snake exists
    if #self.segments == 0 or not self.segments[1] then
        return
    end

    -- Process direction queue
    if #self.directionQueue > 1 then
        table.remove(self.directionQueue, 1)
    end

    local head = self.segments[1]
    local nextX = head.x
    local nextY = head.y

    -- Calculate next position based on direction
    local direction = self.directionQueue[1]
    if direction == 'right' then
        nextX = nextX + 1
        if nextX > gridWidth then
            nextX = 1
        end
    elseif direction == 'left' then
        nextX = nextX - 1
        if nextX < 1 then
            nextX = gridWidth
        end
    elseif direction == 'down' then
        nextY = nextY + 1
        if nextY > gridHeight then
            nextY = 1
        end
    elseif direction == 'up' then
        nextY = nextY - 1
        if nextY < 1 then
            nextY = gridHeight
        end
    end

    -- Add new head segment
    table.insert(self.segments, 1, {x = nextX, y = nextY})

    -- Check for self-collision and handle tail eating
    local collisionIndex = nil
    for i = 2, #self.segments do
        if self.segments[1].x == self.segments[i].x and self.segments[1].y == self.segments[i].y then
            collisionIndex = i
            break
        end
    end
    
    if collisionIndex then
        -- Remove all segments behind the collision point
        for i = #self.segments, collisionIndex, -1 do
            table.remove(self.segments, i)
        end
    end

    return not collisionIndex  -- Return true if no collision occurred (for tail removal decision)
end

function Snake:addDirection(direction)
    local lastDirection = self.directionQueue[#self.directionQueue]
    
    -- Prevent opposite direction inputs
    if direction == 'right' and lastDirection ~= 'right' and lastDirection ~= 'left' then
        table.insert(self.directionQueue, 'right')
    elseif direction == 'left' and lastDirection ~= 'left' and lastDirection ~= 'right' then
        table.insert(self.directionQueue, 'left')
    elseif direction == 'up' and lastDirection ~= 'up' and lastDirection ~= 'down' then
        table.insert(self.directionQueue, 'up')
    elseif direction == 'down' and lastDirection ~= 'down' and lastDirection ~= 'up' then
        table.insert(self.directionQueue, 'down')
    end
end

function Snake:checkAppleCollision(apples)
    if #self.segments == 0 or not self.segments[1] then
        return nil
    end

    local head = self.segments[1]
    for i, apple in ipairs(apples) do
        if head.x == apple.x and head.y == apple.y then
            return i, apple  -- Return index and apple data
        end
    end
    return nil
end

function Snake:activateSpeedBoost()
    self.isSpeedBoosted = true
    self.speedBoostTimer = config.BOOST_DURATION
    self.isFlashing = true  -- This will stay true as long as speed boost is active
end

function Snake:extendBoost()
    if self.isSpeedBoosted then
        self.speedBoostTimer = self.speedBoostTimer + 0.25
    end
end

function Snake:removeTail()
    if #self.segments > 0 then
        table.remove(self.segments)
    end
end

function Snake:reset(x, y, direction)
    self.segments = {
        {x = x, y = y},
        {x = x, y = y + 1},
        {x = x, y = y + 2}
    }
    self.directionQueue = {direction or 'up'}
    self.moveTimer = 0
    self.isSpeedBoosted = false
    self.speedBoostTimer = 0
    self.isFlashing = false
end

function Snake:isEmpty()
    return #self.segments == 0
end

function Snake:getLength()
    return #self.segments
end

function Snake:getHeadPosition()
    if #self.segments > 0 then
        return self.segments[1].x, self.segments[1].y
    end
    return nil, nil
end

function Snake:getCurrentDirection()
    return self.directionQueue[1] or 'up'
end

function Snake:draw(sprites, offsetX, offsetY, cellSize, gridWidth, gridHeight)
    if #self.segments == 0 then return end

    -- Debug: Print snake boost state (remove this after debugging)
    if config.DEBUG_MODE then
        print("Snake state - isSpeedBoosted:", self.isSpeedBoosted, "isFlashing:", self.isFlashing, "timer:", self.speedBoostTimer)
    end

    -- Determine snake color based on boost and flash state
    local snakeColor = {1, 1, 1}  -- Default white
    if self.isSpeedBoosted then
        if self.isFlashing then
            -- Alternate between gold and white every flash interval
            local flashCycle = math.floor(love.timer.getTime() / config.TIMERS.FLASH_INTERVAL) % 2
            if flashCycle == 0 then
                snakeColor = config.COLORS.GOLD
            else
                snakeColor = config.COLORS.WHITE
            end
        else
            snakeColor = config.COLORS.GOLD  -- Solid gold during boost
        end
    else
        snakeColor = config.COLORS.WHITE  -- White when not boosted
    end
    
    love.graphics.setColor(snakeColor[1], snakeColor[2], snakeColor[3])

    -- Draw head
    if self.segments[1] then
        local headDir = self:getCurrentDirection()
        local headRot = 0
        if headDir == 'up' then
            headRot = 0            -- default sprite faces up
        elseif headDir == 'right' then
            headRot = math.pi/2    -- 90 degrees
        elseif headDir == 'down' then
            headRot = math.pi      -- 180 degrees
        elseif headDir == 'left' then
            headRot = math.pi*1.5  -- 270 degrees
        end

        sprites:draw(
            "SNAKE_HEAD_1",
            (self.segments[1].x-1) * cellSize + offsetX + cellSize/2,
            (self.segments[1].y-1) * cellSize + offsetY + cellSize/2,
            headRot,
            cellSize / 16,
            cellSize / 16,
            8, 8  -- 16x16 sprite: origin (16/2, 16/2) = (8, 8)
        )
    end

    -- Draw second segment (neck)
    if #self.segments > 1 and self.segments[2] then
        local dx = self.segments[2].x - self.segments[1].x
        local dy = self.segments[2].y - self.segments[1].y
        local secondRot = 0
        if dy == -1 or dy > 1 then
            secondRot = math.pi  -- down (swap with up)
        elseif dx == 1 or dx < -1 then
            secondRot = math.pi*1.5
        elseif dy == 1 or dy < -1 then
            secondRot = 0        -- up (swap with down)
        elseif dx == -1 or dx > 1 then
            secondRot = math.pi/2
        end
        sprites:draw(
            "SNAKE_HEAD_2",
            (self.segments[2].x-1) * cellSize + offsetX + cellSize/2,
            (self.segments[2].y-1) * cellSize + offsetY + cellSize/2,
            secondRot,
            cellSize / 14,
            cellSize / 16,
            7, 8  -- 14x16 sprite: origin (14/2, 16/2) = (7, 8)
        )
    end

    -- Draw body segments (from 3rd to last)
    if #self.segments > 2 then
        for i = 3, #self.segments do
            local prev = self.segments[i-1]
            local curr = self.segments[i]
            local next = self.segments[i+1]
            
            if curr and prev then
                -- Check if this is a corner (turning) segment
                local isCorner = false
                
                if next then
                    -- Only corner if THIS is where direction changed
                    if i < #self.segments then
                        local behind = self.segments[i+1]
                        if behind then
                            local dx1 = prev.x - curr.x  -- direction from current to previous
                            local dy1 = prev.y - curr.y
                            local dx3 = curr.x - behind.x  -- direction from behind to current
                            local dy3 = curr.y - behind.y
                            
                            -- Normalize wrap-around movements
                            if dx1 > 1 then dx1 = dx1 - gridWidth end
                            if dx1 < -1 then dx1 = dx1 + gridWidth end
                            if dy1 > 1 then dy1 = dy1 - gridHeight end
                            if dy1 < -1 then dy1 = dy1 + gridHeight end
                            if dx3 > 1 then dx3 = dx3 - gridWidth end
                            if dx3 < -1 then dx3 = dx3 + gridWidth end
                            if dy3 > 1 then dy3 = dy3 - gridHeight end
                            if dy3 < -1 then dy3 = dy3 + gridHeight end
                            
                            -- Corner only if direction FROM behind is different than direction TO next
                            if (dx1 ~= dx3) or (dy1 ~= dy3) then
                                isCorner = true
                            end
                        end
                    end
                    
                    if isCorner then
                        self:drawCornerSegment(sprites, curr, prev, next, offsetX, offsetY, cellSize, gridWidth, gridHeight)
                    end
                end
                
                if not isCorner then
                    self:drawBodySegment(sprites, curr, prev, offsetX, offsetY, cellSize)
                end
            end
        end
    end
    
    -- Reset color to white
    love.graphics.setColor(1, 1, 1)
end

function Snake:drawCornerSegment(sprites, curr, prev, next, offsetX, offsetY, cellSize, gridWidth, gridHeight)
    local dx1 = prev.x - curr.x
    local dy1 = prev.y - curr.y
    local dx2 = next.x - curr.x
    local dy2 = next.y - curr.y
    
    -- Normalize wrap-around movements
    if dx1 > 1 then dx1 = dx1 - gridWidth end
    if dx1 < -1 then dx1 = dx1 + gridWidth end
    if dy1 > 1 then dy1 = dy1 - gridHeight end
    if dy1 < -1 then dy1 = dy1 + gridHeight end
    if dx2 > 1 then dx2 = dx2 - gridWidth end
    if dx2 < -1 then dx2 = dx2 + gridWidth end
    if dy2 > 1 then dy2 = dy2 - gridHeight end
    if dy2 < -1 then dy2 = dy2 + gridHeight end
    
    local cornerRot = 0
    local scaleX = cellSize / 15
    local scaleY = cellSize / 15
    
    -- Determine corner rotation and flipping based on turn direction
    if dx1 == 0 and dy1 == 1 and dx2 == -1 and dy2 == 0 then -- down to left
        cornerRot = 0
        scaleY = -scaleY
    elseif dx1 == -1 and dy1 == 0 and dx2 == 0 and dy2 == -1 then -- left to up
        cornerRot = 0
    elseif dx1 == 0 and dy1 == -1 and dx2 == 1 and dy2 == 0 then -- up to right
        cornerRot = 0
        scaleX = -scaleX
        scaleY = -scaleY
    elseif dx1 == 1 and dy1 == 0 and dx2 == 0 and dy2 == 1 then -- right to down
        cornerRot = 0
        scaleX = -scaleX
    elseif dx1 == 0 and dy1 == 1 and dx2 == 1 and dy2 == 0 then -- down to right
        cornerRot = math.pi/2
    elseif dx1 == 1 and dy1 == 0 and dx2 == 0 and dy2 == -1 then -- right to up
        cornerRot = math.pi
    elseif dx1 == 0 and dy1 == -1 and dx2 == -1 and dy2 == 0 then -- up to left
        cornerRot = math.pi*1.5
    elseif dx1 == -1 and dy1 == 0 and dx2 == 0 and dy2 == 1 then -- left to down
        cornerRot = 0
        scaleX = -scaleX
    end
    
    sprites:draw(
        "SNAKE_BODY_CORNER",
        (curr.x-1) * cellSize + offsetX + cellSize/2,
        (curr.y-1) * cellSize + offsetY + cellSize/2,
        cornerRot,
        scaleX,
        scaleY,
        7.5, 7.5
    )
end

function Snake:drawBodySegment(sprites, curr, prev, offsetX, offsetY, cellSize)
    local dx = curr.x - prev.x
    local dy = curr.y - prev.y
    local rot = 0
    if dy == -1 or dy > 1 then
        rot = 0
    elseif dx == 1 or dx < -1 then
        rot = math.pi*1.5
    elseif dy == 1 or dy < -1 then
        rot = math.pi
    elseif dx == -1 or dx > 1 then
        rot = math.pi/2
    end
    sprites:draw(
        "SNAKE_BODY",
        (curr.x-1) * cellSize + offsetX + cellSize/2,
        (curr.y-1) * cellSize + offsetY + cellSize/2,
        rot,
        cellSize / 14,
        cellSize / 16,
        7, 8
    )
end

return Snake