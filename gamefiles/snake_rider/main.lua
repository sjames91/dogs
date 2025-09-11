-- Spawns an apple not on the snake or other apples
function spawnApple()
    local available = {}
    -- Build a set of occupied positions for fast lookup
    local occupied = {}
    for _, segment in ipairs(snakeSegments) do
        occupied[segment.x .. ',' .. segment.y] = true
    end
    -- Mark existing apple positions as occupied
    for _, apple in ipairs(apples) do
        occupied[apple.x .. ',' .. apple.y] = true
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
        local newApple = {
            x = pos.x, 
            y = pos.y, 
            timer = love.math.random(5, 15) -- Random lifetime 5-15 seconds
        }
        table.insert(apples, newApple)
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
   
    apples = {}  -- Array to hold multiple apples
    appleSpawnTimer = 0  -- Timer for spawning new apples
    
    -- Spawn initial apple
    spawnApple()

    time = 0
    countdownTime = 100
    timer = 0
    score = 0
    gameState = "playing"  -- "playing" or "showingScore"
    finalScoreTimer = 0
    finalScore = 0

    directionQueue = {'null'}

end

function love.update(dt)
    time = time + dt
    countdownTime = countdownTime - dt

    -- Update apple timers and remove expired apples
    for i = #apples, 1, -1 do
        apples[i].timer = apples[i].timer - dt
        if apples[i].timer <= 0 then
            table.remove(apples, i)
        end
    end
    
    -- Spawn new apples periodically
    appleSpawnTimer = appleSpawnTimer + dt
    if appleSpawnTimer >= 1.5 then  -- Spawn every 1.5 seconds (twice as fast)
        appleSpawnTimer = 0
        if #apples < 5 then  -- Limit to 5 apples on screen
            spawnApple()
        end
    end

    -- Reset game when timer hits 0
    if countdownTime <= 0 and gameState == "playing" then
        -- Calculate final score with segment multiplier (excluding head and neck)
        local segmentMultiplier = math.max(0, #snakeSegments - 2)
        finalScore = score * segmentMultiplier
        if finalScore > highScore then
            highScore = finalScore
            -- Save new high score to file
            love.filesystem.write("highscore.txt", tostring(highScore))
        end
        
        apples = {}  -- Clear all apples when showing final score
        gameState = "showingScore"
        finalScoreTimer = 5  -- Show for 5 seconds
    end
    
    -- Handle score display countdown
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
            countdownTime = 100
            time = 0
            score = 0
            apples = {}
            appleSpawnTimer = 0
            spawnApple()
            gameState = "playing"
        end
        return  -- Don't process game logic during score display
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

        -- Check for apple collision
        local appleEaten = false
        for i = #apples, 1, -1 do
            if snakeSegments[1].x == apples[i].x and snakeSegments[1].y == apples[i].y then
                score = score + 10
                table.remove(apples, i)
                appleEaten = true
                break
            end
        end
        
        if not appleEaten then
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

    -- draw apples (preserve aspect ratio)
    local qw, qh = 10, 15
    local margin = 1
    local scale = math.min((cellSize - margin) / qw, (cellSize - margin) / qh)

    for _, apple in ipairs(apples) do
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

    -- Set larger font for text
    love.graphics.setFont(love.graphics.newFont(24))
    
    if gameState == "showingScore" then
        -- Show final score in center of screen
        love.graphics.setFont(love.graphics.newFont(96))  -- 4x larger than normal text
        local text = "Final Score: " .. finalScore
        local textWidth = love.graphics.getFont():getWidth(text)
        local textHeight = love.graphics.getFont():getHeight()
        love.graphics.print(text, 
            (love.graphics.getWidth() - textWidth) / 2,
            (love.graphics.getHeight() - textHeight) / 2)
    else
        -- Normal gameplay UI
        love.graphics.print("Time Left: " .. math.ceil(countdownTime), 10, 10)
        love.graphics.print("Score: " .. score, love.graphics.getWidth() - 200, 10)
        love.graphics.print("High Score: " .. highScore, love.graphics.getWidth() - 230, 40)
    end
end