
local apple_spawns = require("item_spawns")
local config = require("game_config")
local SpriteManager = require("sprite_manager")

-- Global sprite managers
local sprites -- Main character sprites

function love.load() 
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    -- Initialize sprite managers for different sprite sheets
    sprites = SpriteManager.register("CHARACTERS", 
        config.SPRITE_SHEETS.CHARACTERS.path, 
        config.SPRITE_SHEETS.CHARACTERS.sprites)
    
    -- Future sprite managers would be:
    -- SpriteManager.register("UI", config.SPRITE_SHEETS.UI.path, config.SPRITE_SHEETS.UI.sprites)
    -- SpriteManager.register("EFFECTS", config.SPRITE_SHEETS.EFFECTS.path, config.SPRITE_SHEETS.EFFECTS.sprites)
    
    -- Or load from JSON:
    -- SpriteManager.registerFromJSON("CHARACTERS", "sprites.json")
    
    cellSize = config.CELL_SIZE
    gridWidth = config.GRID_WIDTH
    gridHeight = config.GRID_HEIGHT
    -- Window size and title are now set in conf.lua
    gridXcount = gridWidth
    gridYcount = gridHeight

    -- Load high score from file
    local saveData = love.filesystem.read("highscore.txt")
    if saveData then
        highScore = tonumber(saveData) or 0
    else
        highScore = 0
    end

    -- Set window icon to snake head sprite
    local iconImageData = love.image.newImageData(16, 16)
    local spritesheet = love.image.newImageData(config.SPRITE_PATH)
    iconImageData:paste(spritesheet, 0, 0, 0, 16, 16, 16)
    love.window.setIcon(iconImageData)

    snakeSegments = {
        {x=12, y=8},
        {x=12, y=9},
        {x=12, y=10},
    }
   
    apples = {}  -- Array to hold multiple apples
    appleSpawnTimer = 0  -- Timer for spawning new apples
    goldAppleSpawnTimer = 0  -- Timer for spawning gold apples
    
    -- Don't spawn initial apple - wait for space press

    time = 0
    countdownTime = config.GAME_DURATION
    timer = 0
    score = 0
    applesEaten = 0  -- Track number of apples eaten
    gameState = "waiting"  -- "waiting", "playing" or "showingScore"
    finalScoreTimer = 0
    finalScore = 0
    directionQueue = {'up'}
    
    -- Add speed boost variables
    speedBoostTimer = 0
    isSpeedBoosted = false
    
    -- Add visual effects
    flashTimer = 0
    isFlashing = false
    particles = {}  -- Array to hold particle effects
end

function love.update(dt)
    -- Handle score display countdown first
    if gameState == "showingScore" then
        finalScoreTimer = finalScoreTimer - dt
        if finalScoreTimer <= 0 then
            -- Reset game
            snakeSegments = {
                {x=12, y=8},
                {x=12, y=9},
                {x=12, y=10},
            }
            directionQueue = {'null'}
            countdownTime = config.GAME_DURATION
            time = 0
            score = 0
            applesEaten = 0
            apples = {}
            appleSpawnTimer = 0
            goldAppleSpawnTimer = 0  -- Reset gold apple timer too
            -- Reset speed boost
            isSpeedBoosted = false
            speedBoostTimer = 0
            -- Reset visual effects
            isFlashing = false
            flashTimer = 0
            particles = {}
            gameState = "waiting"  -- Start in waiting state
        end
        return  -- Don't process game logic during score display
    end
    
    -- Only update game logic when playing
    if gameState ~= "playing" then
        return
    end
    
    time = time + dt
    countdownTime = countdownTime - dt

    -- Update apple timers and remove expired apples
    for i = #apples, 1, -1 do
        apples[i].timer = apples[i].timer - dt
        if apples[i].timer <= 0 then
            table.remove(apples, i)
        end
    end
    
    -- Update speed boost timer
    if isSpeedBoosted then
        speedBoostTimer = speedBoostTimer - dt
        if speedBoostTimer <= 0 then
            isSpeedBoosted = false
            speedBoostTimer = 0
            isFlashing = false  -- Stop flashing when boost ends
        end
    end

    -- Update flash timer
    if isFlashing then
        flashTimer = flashTimer - dt
        if flashTimer <= 0 then
            isFlashing = false
        end
    end

    -- Update particles
    for i = #particles, 1, -1 do
        particles[i].timer = particles[i].timer - dt
        if particles[i].timer <= 0 then
            table.remove(particles, i)
        else
            -- Move particle
            particles[i].x = particles[i].x + particles[i].vx * dt
            particles[i].y = particles[i].y + particles[i].vy * dt
        end
    end

    -- Spawn new apples periodically (faster during speed boost)
    appleSpawnTimer = appleSpawnTimer + dt
    local spawnRate = isSpeedBoosted and 0.75 or 1.5  -- Twice as fast during boost
    if appleSpawnTimer >= spawnRate then
        appleSpawnTimer = 0
        if #apples < 10 then  -- Limit to 10 apples on screen
            apple_spawns.spawnApple()
        end
    end

    -- Spawn gold apples much less frequently
    goldAppleSpawnTimer = goldAppleSpawnTimer + dt
    if goldAppleSpawnTimer >= 20 then -- Every 20 seconds
        goldAppleSpawnTimer = 0
        -- Only spawn if there isn't already a gold apple
        local hasGold = false
        for _, apple in ipairs(apples) do
            if apple.gold then
                hasGold = true
                break
            end
        end
        if not hasGold then
            apple_spawns.spawnGoldApple()
        end
    end

    -- Reset game when timer hits 0
    if countdownTime <= 0 and gameState == "playing" then
        -- Final score is already calculated with the formula
        finalScore = score
        isNewHighScore = false
        if finalScore > highScore then
            highScore = finalScore
            isNewHighScore = true
            -- Save new high score to file
            love.filesystem.write("highscore.txt", tostring(highScore))
        end
        
        apples = {}  -- Clear all apples when showing final score
        gameState = "showingScore"
        finalScoreTimer = 5  -- Show for 5 seconds
    end

    timer = timer + dt
    -- Snake moves faster during speed boost
    local moveSpeed = isSpeedBoosted and 0.075 or 0.15  -- Double speed during boost
    if timer >= moveSpeed then
        timer = 0
        time = time + dt
        
        -- Only move the snake if it exists
        if #snakeSegments > 0 and snakeSegments[1] then
            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end

            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y

        if directionQueue[1] == 'right' then
            nextXPosition = nextXPosition + 1
            if nextXPosition > gridXcount then
                nextXPosition = 1
            end

        elseif directionQueue[1] == 'left' then
            nextXPosition = nextXPosition - 1
            if nextXPosition < 1 then
                nextXPosition = gridXcount
            end

        elseif directionQueue[1] == 'down' then
            nextYPosition = nextYPosition + 1
            if nextYPosition > gridYcount then
                nextYPosition = 1
            end

        elseif directionQueue[1] == 'up' then
            nextYPosition = nextYPosition - 1
            if nextYPosition < 1 then
                nextYPosition = gridYcount
            end
        end

        table.insert(snakeSegments, 1, {
            x = nextXPosition, y = nextYPosition    
        })

        -- Check for self-collision and eat tail if so
        local collisionIndex = nil
        for i = 2, #snakeSegments do
            if snakeSegments[1].x == snakeSegments[i].x and snakeSegments[1].y == snakeSegments[i].y then
                collisionIndex = i
                break
            end
        end
        if collisionIndex then
            -- Remove all segments behind the collision point
            for i = #snakeSegments, collisionIndex, -1 do
                table.remove(snakeSegments, i)
            end
        end

        -- Check for apple collision
        local appleEaten = false
        for i = #apples, 1, -1 do
            if snakeSegments[1].x == apples[i].x and snakeSegments[1].y == apples[i].y then
                -- Gold apples are worth 10 regular apples
                if apples[i].gold then
                    applesEaten = applesEaten + 10
                    -- Activate speed boost for 10 seconds
                    isSpeedBoosted = true
                    speedBoostTimer = 11.0
                    
                    -- Create particle effect at apple position
                    local offsetX = (love.graphics.getWidth() - (gridXcount * cellSize)) / 2
                    local offsetY = (love.graphics.getHeight() - (gridYcount * cellSize)) / 2
                    local centerX = (apples[i].x-1) * cellSize + offsetX + cellSize/2
                    local centerY = (apples[i].y-1) * cellSize + offsetY + cellSize/2
                    
                    -- Create 12 particles in different directions
                    for j = 1, 12 do
                        local angle = (j / 12) * math.pi * 2
                        local speed = love.math.random(100, 200)
                        table.insert(particles, {
                            x = centerX,
                            y = centerY,
                            vx = math.cos(angle) * speed,
                            vy = math.sin(angle) * speed,
                            timer = 0.3,
                            maxTimer = 0.3
                        })
                    end
                    
                    -- Start flashing during boost
                    isFlashing = true
                    flashTimer = speedBoostTimer  -- Flash for entire boost duration
                else
                    applesEaten = applesEaten + 1
                    -- Add 1 second to boost timer if currently boosted
                    if isSpeedBoosted then
                        speedBoostTimer = speedBoostTimer + 0.25
                    end
                end
                score = 10 * applesEaten * #snakeSegments  -- Recalculate total score
                table.remove(apples, i)
                appleEaten = true
                break
            end
        end
        
        if not appleEaten then
            table.remove(snakeSegments)
            -- Recalculate score after losing a segment
            score = 10 * applesEaten * #snakeSegments
        end
        end -- Close the snake existence check
    end
    
    -- Respawn snake if it's completely gone
    if #snakeSegments == 0 then
        snakeSegments = {
            {x=12, y=8},
            {x=12, y=9},
            {x=12, y=10},
        }
        directionQueue = {'up'}
    end
end

function love.keypressed(key, scancode)

    if scancode == "s" then key = "down"
        elseif scancode == "w" then key = "up"
        elseif scancode == "d" then key = "right"
        elseif scancode == "a" then key = "left"    
    end

    if key == "escape" then
        love.event.quit()
    end
    
    if key == "up" and gameState == "waiting" then
        gameState = "playing"
        directionQueue = {'up'}  -- Set initial direction to up
        apple_spawns.spawnApple()  -- Spawn first apple when game starts
        return
    end
    
    if gameState ~= "playing" then
        return
    end

    if key == "right" 
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then 
        table.insert(directionQueue, 'right')

    elseif key == 'left' 
    and directionQueue[#directionQueue] ~= 'left'
    and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')

    elseif key == 'up'
    and directionQueue[#directionQueue] ~= 'up' 
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif key == 'down' 
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end

function love.draw()
    -- Set background color and fill the screen
    love.graphics.setColor(1.0, 0.8, 0.9)  -- Pink background
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)  -- Reset to white for other drawing
    local offsetX = (love.graphics.getWidth() - (gridXcount * cellSize)) / 2
    local offsetY = (love.graphics.getHeight() - (gridYcount * cellSize)) / 2
    -- Determine rotation for head based on direction
    local headDir = directionQueue[1] or 'right'
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

    -- Determine snake color based on boost and flash state
    local snakeColor = {1, 1, 1}  -- Default white
    if isSpeedBoosted then
        if isFlashing then
            -- Alternate between gold and white every 0.1 seconds
            local flashCycle = math.floor(love.timer.getTime() / 0.1) % 2
            if flashCycle == 0 then
                snakeColor = {1, 0.84, 0}  -- Gold
            else
                snakeColor = {1, 1, 1}     -- White
            end
        else
            snakeColor = {1, 0.84, 0}  -- Solid gold during boost
        end
    else
        -- Boost has ended - force normal white color
        snakeColor = {1, 1, 1}  -- White
    end
    
    love.graphics.setColor(snakeColor[1], snakeColor[2], snakeColor[3])

    -- Only draw the head if the snake exists
    if #snakeSegments > 0 and snakeSegments[1] then
        sprites:draw(
            "SNAKE_HEAD_1",
            (snakeSegments[1].x-1) * cellSize + offsetX + cellSize/2,
            (snakeSegments[1].y-1) * cellSize + offsetY + cellSize/2,
            headRot,
            cellSize / 16,
            cellSize / 16,
            8, 8  -- 16x16 sprite: origin (16/2, 16/2) = (8, 8)
        )
    end

    -- Draw the second segment (neck) if it exists
    if #snakeSegments > 1 and snakeSegments[2] then
        local dx = snakeSegments[2].x - snakeSegments[1].x
        local dy = snakeSegments[2].y - snakeSegments[1].y
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
            (snakeSegments[2].x-1) * cellSize + offsetX + cellSize/2,
            (snakeSegments[2].y-1) * cellSize + offsetY + cellSize/2,
            secondRot,
            cellSize / 14,
            cellSize / 16,
            7, 8  -- 14x16 sprite: origin (14/2, 16/2) = (7, 8)
        )
    end

    -- Draw all body segments (from 3rd to last) if they exist
    if #snakeSegments > 2 then
        for i = 3, #snakeSegments do
            local prev = snakeSegments[i-1]
            local curr = snakeSegments[i]
            local next = snakeSegments[i+1]
            
            if curr and prev then
                -- Check if this is a corner (turning) segment
                local isCorner = false
                local cornerRot = 0
                
                if next then
                    -- Get direction vectors
                    local dx1 = prev.x - curr.x  -- direction from current to previous
                    local dy1 = prev.y - curr.y
                    local dx2 = next.x - curr.x  -- direction from current to next
                    local dy2 = next.y - curr.y
                    
                    -- Normalize wrap-around movements
                    if dx1 > 1 then dx1 = dx1 - gridXcount end
                    if dx1 < -1 then dx1 = dx1 + gridXcount end
                    if dy1 > 1 then dy1 = dy1 - gridYcount end
                    if dy1 < -1 then dy1 = dy1 + gridYcount end
                    if dx2 > 1 then dx2 = dx2 - gridXcount end
                    if dx2 < -1 then dx2 = dx2 + gridXcount end
                    if dy2 > 1 then dy2 = dy2 - gridYcount end
                    if dy2 < -1 then dy2 = dy2 + gridYcount end
                    
                    -- Only corner if THIS is where direction changed (check with segment behind it)
                    if i < #snakeSegments then
                        local behind = snakeSegments[i+1]
                        if behind then
                            local dx3 = curr.x - behind.x  -- direction from behind to current
                            local dy3 = curr.y - behind.y
                            
                            -- Normalize wrap-around
                            if dx3 > 1 then dx3 = dx3 - gridXcount end
                            if dx3 < -1 then dx3 = dx3 + gridXcount end
                            if dy3 > 1 then dy3 = dy3 - gridYcount end
                            if dy3 < -1 then dy3 = dy3 + gridYcount end
                            
                            -- Corner only if direction FROM behind is different than direction TO next
                            if (dx1 ~= dx3) or (dy1 ~= dy3) then
                                isCorner = true
                            end
                        end
                    end
                    
                    if isCorner then
                        -- Determine corner rotation and flipping based on turn direction
                        -- Base sprite is left→up, so we rotate/flip from that reference
                        local scaleX = cellSize / 15
                        local scaleY = cellSize / 15
                        
                        if dx1 == 0 and dy1 == 1 and dx2 == -1 and dy2 == 0 then -- down to left
                            cornerRot = 0  -- no rotation
                            scaleY = -scaleY  -- flip Y (horizontal flip)
                        elseif dx1 == -1 and dy1 == 0 and dx2 == 0 and dy2 == -1 then -- left to up
                            cornerRot = 0  -- Base orientation (left→up)
                        elseif dx1 == 0 and dy1 == -1 and dx2 == 1 and dy2 == 0 then -- up to right
                            cornerRot = 0  -- no rotation
                            scaleX = -scaleX  -- flip X (vertical flip)
                            scaleY = -scaleY  -- flip Y (horizontal flip)
                        elseif dx1 == 1 and dy1 == 0 and dx2 == 0 and dy2 == 1 then -- right to down
                            cornerRot = 0  -- no rotation
                            scaleX = -scaleX  -- flip X (vertical flip)
                        elseif dx1 == 0 and dy1 == 1 and dx2 == 1 and dy2 == 0 then -- down to right
                            cornerRot = math.pi/2  -- 90° rotation
                        elseif dx1 == 1 and dy1 == 0 and dx2 == 0 and dy2 == -1 then -- right to up
                            cornerRot = math.pi  -- 180° rotation
                        elseif dx1 == 0 and dy1 == -1 and dx2 == -1 and dy2 == 0 then -- up to left
                            cornerRot = math.pi*1.5  -- 270° rotation
                        elseif dx1 == -1 and dy1 == 0 and dx2 == 0 and dy2 == 1 then -- left to down
                            cornerRot = 0  -- no rotation
                            scaleX = -scaleX  -- flip X (vertical flip)
                        end
                        
                        -- Draw corner piece with flipping
                        sprites:draw(
                            "SNAKE_BODY_CORNER",
                            (curr.x-1) * cellSize + offsetX + cellSize/2,
                            (curr.y-1) * cellSize + offsetY + cellSize/2,
                            cornerRot,
                            scaleX,  -- Can be negative for flipping
                            scaleY,  -- Can be negative for flipping
                            7.5, 7.5  -- 15x15 sprite: origin (15/2, 15/2) = (7.5, 7.5)
                        )
                    end
                end
                
                if not isCorner then
                    -- Draw regular body segment
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
                        7, 8  -- 14x16 sprite: origin (14/2, 16/2) = (7, 8)
                    )
                end
            end
        end
    end
    
    -- Reset color to white before drawing UI and other elements
    love.graphics.setColor(1, 1, 1)

    -- draw apples (preserve aspect ratio)
    local qw, qh = 10, 15
    local margin = 1
    local scale = math.min((cellSize - margin) / qw, (cellSize - margin) / qh)

    for _, apple in ipairs(apples) do
        -- Use gold sprite for gold apples, red sprite for regular apples
        local spriteName = apple.gold and "GOLD_APPLE" or "RED_APPLE"
        sprites:draw(
            spriteName,
            (apple.x-1) * cellSize + offsetX + cellSize/2,
            (apple.y-1) * cellSize + offsetY + cellSize/2,
            0,
            scale, scale,
            qw/2, qh/2
        )
    end

    -- Set larger font for text
    love.graphics.setFont(love.graphics.newFont(24))
    
    if gameState == "showingScore" then
        -- Show final score or new high score in center of screen
        love.graphics.setFont(love.graphics.newFont(96))  -- 4x larger than normal text
        local text
        if isNewHighScore then
            text = "NEW HIGH SCORE " .. finalScore
        else
            text = "FINAL SCORE " .. finalScore
        end
        local textWidth = love.graphics.getFont():getWidth(text)
        local textHeight = love.graphics.getFont():getHeight()
        love.graphics.print(text, 
            (love.graphics.getWidth() - textWidth) / 2,
            (love.graphics.getHeight() - textHeight) / 2)
    elseif gameState == "waiting" then
        -- Show "Press Space to Start" above snake's initial position
        love.graphics.setFont(love.graphics.newFont(96))  -- Same size as final score
        local text = "PRESS UP TO START"
        local textWidth = love.graphics.getFont():getWidth(text)
        local snakeY = (8-1) * cellSize + offsetY  -- Snake's first segment Y position
        love.graphics.print(text, 
            (love.graphics.getWidth() - textWidth) / 2,
            snakeY - (4 * cellSize) - 16)  -- 4 cells higher + 16 pixels above snake
    else
        -- Normal gameplay UI
        love.graphics.print("TIME LEFT: " .. math.ceil(countdownTime), 10, 10)
        love.graphics.print("SCORE: " .. score, 10, 40)
        love.graphics.print("HIGH SCORE: " .. highScore, 10, 70)
        
        -- Show speed boost indicator
        if isSpeedBoosted then
            love.graphics.setColor(1, 1, 0)  -- Yellow text
            love.graphics.print("SPEED BOOST: " .. string.format("%.1f", speedBoostTimer), 10, 100)
            love.graphics.setColor(1, 1, 1)  -- Reset to white
        end
    end

    -- Reset color to white for other drawing
    love.graphics.setColor(1, 1, 1)

    -- Draw particles
    for _, particle in ipairs(particles) do
        local alpha = particle.timer / particle.maxTimer  -- Fade out over time
        love.graphics.setColor(1, 0.84, 0, alpha)  -- Gold with fading alpha
        love.graphics.circle("fill", particle.x, particle.y, 3)  -- Small 3-pixel circles
    end
    
    love.graphics.setColor(1, 1, 1)  -- Reset color
end