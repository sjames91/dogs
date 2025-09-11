-- Spawns an apple not on the snake (simple method)
function spawnApple()
    local available = {}
    -- Build a set of occupied positions for fast lookup
    local occupied = {}
    for _, segment in ipairs(snakeSegments) do
        occupied[segment.x .. ',' .. segment.y] = true
    end
    -- Collect all unoccupied positions
    for x = 1, gridXcount do
        for y = 1, gridYcount do
            if not occupied[x .. ',' .. y] then
                table.insert(available, {x = x, y = y})
            end
        end
    end
    -- Pick a random available position
    if #available > 0 then
        local pos = available[love.math.random(1, #available)]
        apple = {x = pos.x, y = pos.y}
    else
        apple = nil -- No space left!
    end
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    characterspritesheet1 = love.graphics.newImage("assets/characters_sprites/characterspritesheet1.png") 
    cellSize = 64
    gridWidth = 24
    gridHeight = 16
    love.window.setMode(gridWidth * cellSize, gridHeight * cellSize)
    gridXcount = gridWidth
    gridYcount = gridHeight

    -- Load high score from file
    local saveData = love.filesystem.read("highscore.txt")
    if saveData then
        highScore = tonumber(saveData) or 0
    else
        highScore = 0
    end

    snakeheadsprite1 = love.graphics.newQuad(
        0, 16,
        16, 16,    
        characterspritesheet1:getWidth(),
        characterspritesheet1:getHeight()
    )
    snakeheadsprite2 = love.graphics.newQuad(
        0, 32,
        16, 16,

        characterspritesheet1:getWidth(),
        characterspritesheet1:getHeight()
    )
    snakebodysprite = love.graphics.newQuad(
        0, 48,
        16, 16,

    characterspritesheet1:getWidth(),
    characterspritesheet1:getHeight()
    )

    redapplesprite = love.graphics.newQuad(
        18, 32,
        10, 15,

        characterspritesheet1:getWidth(),
        characterspritesheet1:getHeight()
    )


    snakeSegments = {
        {x=12, y=8},
        {x=12, y=9},
        {x=12, y=10},
    }
   
    spawnApple()

    time = 0
    countdownTime = 100
    timer = 0
    score = 0

    directionQueue = {'null'}

end

function love.update(dt)
    time = time + dt
    countdownTime = countdownTime - dt

    -- Reset game when timer hits 0
    if countdownTime <= 0 then
        -- Calculate final score with segment multiplier (excluding head and neck)
        local segmentMultiplier = math.max(0, #snakeSegments - 2)
        local finalScore = score * segmentMultiplier
        if finalScore > highScore then
            highScore = finalScore
            -- Save new high score to file
            love.filesystem.write("highscore.txt", tostring(highScore))
        end
        
        snakeSegments = {
            {x=12, y=8},
            {x=12, y=9},
            {x=12, y=10},
        }
        directionQueue = {'null'}
        countdownTime = 100
        time = 0
        score = 0
        spawnApple()
    end

    timer = timer + dt
    if timer >= 0.15 then
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

        if apple and snakeSegments[1].x == apple.x 
        and snakeSegments[1].y == apple.y then
            score = score + 10
            spawnApple()
        else
            table.remove(snakeSegments)
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
        directionQueue = {'null'}
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
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

    love.graphics.setColor(1.0, 0.8, 0.9)
    love.graphics.draw(characterspritesheet1, snakeheadsprite1, 0, 0)
    love.graphics.setColor(1, 1, 1)
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

    -- Only draw the head if the snake exists
    if #snakeSegments > 0 and snakeSegments[1] then
        love.graphics.draw(
            characterspritesheet1,
            snakeheadsprite1,
            (snakeSegments[1].x-1) * cellSize + offsetX + cellSize/2,
            (snakeSegments[1].y-1) * cellSize + offsetY + cellSize/2,
            headRot,
            cellSize / 16,
            cellSize / 16,
            8, 8
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
        love.graphics.draw(
            characterspritesheet1,
            snakeheadsprite2,
            (snakeSegments[2].x-1) * cellSize + offsetX + cellSize/2,
            (snakeSegments[2].y-1) * cellSize + offsetY + cellSize/2,
            secondRot,
            cellSize / 16,
            cellSize / 16,
            8, 8
        )
    end

    -- Draw all body segments (from 3rd to last) if they exist
    if #snakeSegments > 2 then
        for i = 3, #snakeSegments do
            local prev = snakeSegments[i-1]
            local curr = snakeSegments[i]
            if curr and prev then
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
                love.graphics.draw(
                    characterspritesheet1,
                    snakebodysprite,
                    (curr.x-1) * cellSize + offsetX + cellSize/2,
                    (curr.y-1) * cellSize + offsetY + cellSize/2,
                    rot,
                    cellSize / 16,
                    cellSize / 16,
                    8, 8
                )
            end
        end
    end

    -- draw apple (preserve aspect ratio)
    local qw, qh = 10, 15
    local margin = 1
    local scale = math.min((cellSize - margin) / qw, (cellSize - margin) / qh)

    if apple then
        love.graphics.draw(
            characterspritesheet1,
            redapplesprite,
            (apple.x-1) * cellSize + offsetX + cellSize/2,
            (apple.y-1) * cellSize + offsetY + cellSize/2,
            0,
            scale, scale,
            qw/2, qh/2
        )
    end


    love.graphics.print("Time Left: " .. math.ceil(countdownTime), 10, 10)
    love.graphics.print("Score: " .. score, love.graphics.getWidth() - 120, 10)
    love.graphics.print("High Score: " .. highScore, love.graphics.getWidth() - 150, 30)
end