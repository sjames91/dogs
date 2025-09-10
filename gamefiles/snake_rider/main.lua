
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    characterspritesheet1 = love.graphics.newImage("assets/characters_sprites/characterspritesheet1.png") 
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


    snakeSegments = {
        {x=10, y=7},
        {x=10, y=7},
        {x=10, y=7},
        {x=10, y=7}
    }
   
    time = 0
    countdownTime = 100
    timer = 0

    directionQueue = {'up'}

    cellSize = 16
    gridXcount = math.floor(600 / cellSize)
    gridYcount = math.floor(600 / cellSize)
end

function love.update(dt)
    time = time + dt
    countdownTime = countdownTime - dt

    timer = timer + dt
    if timer >= 0.15 then
        timer = 0
        time = time + dt
        
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
        table.remove(snakeSegments)
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
    local cellSize = 128

    love.graphics.setColor(1.0, 0.8, 0.9)
    love.graphics.draw(characterspritesheet1, snakeheadsprite1, 0, 0)

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(characterspritesheet1, 8, 8)

    love.graphics.draw(
        characterspritesheet1,
        snakeheadsprite1,
        200, 8,  -- Fixed position to see it clearly
        0,
        4, 4       -- Make it 2x bigger so you can see it
    )

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

    love.graphics.draw(
        characterspritesheet1,
        snakeheadsprite1,
        (snakeSegments[1].x-1) * cellSize + cellSize/2,
        (snakeSegments[1].y-1) * cellSize + cellSize/2,
        headRot,
        cellSize / 16,
        cellSize / 16,
        8, 8
    )


    -- Draw the second segment (neck)
    if #snakeSegments > 1 then
        local dx = snakeSegments[2].x - snakeSegments[1].x
        local dy = snakeSegments[2].y - snakeSegments[1].y
        local secondRot = 0
        if dy == -1 or dy > 1 then
            secondRot = 0
        elseif dx == 1 or dx < -1 then
            secondRot = math.pi*1.5
        elseif dy == 1 or dy < -1 then
            secondRot = math.pi
        elseif dx == -1 or dx > 1 then
            secondRot = math.pi/2
        end
        love.graphics.draw(
            characterspritesheet1,
            snakeheadsprite2,
            (snakeSegments[2].x-1) * cellSize + cellSize/2,
            (snakeSegments[2].y-1) * cellSize + cellSize/2,
            secondRot,
            cellSize / 16,
            cellSize / 16,
            8, 8
        )
    end

    -- Draw all body segments (from 3rd to last)
    for i = 3, #snakeSegments do
        local prev = snakeSegments[i-1]
        local curr = snakeSegments[i]
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
            (curr.x-1) * cellSize + cellSize/2,
            (curr.y-1) * cellSize + cellSize/2,
            rot,
            cellSize / 16,
            cellSize / 16,
            8, 8
        )
    end

    love.graphics.print("Time Left: " .. math.ceil(countdownTime), 10, 10)
end