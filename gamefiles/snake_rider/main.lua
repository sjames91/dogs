
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    characterspritesheet1 = love.graphics.newImage("assets/characters_sprites/characterspritesheet1.png")
    
    snakeheadsprite = love.graphics.newQuad(
        0, 16,
        16, 32,
        characterspritesheet1:getWidth(),
        characterspritesheet1:getHeight()
    )


    snakeSegments = {
        {x=10, y=7},
        {x=9, y=7},
        {x=8, y=7}
    }
   
    time = 0
    countdownTime = 100
    timer = 0

    directionQueue = {'right'}

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
    love.graphics.draw(characterspritesheet1, snakeheadsprite, 0, 0)

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(characterspritesheet1, 8, 8)

    love.graphics.draw(
        characterspritesheet1,
        snakeheadsprite,
        200, 8,  -- Fixed position to see it clearly
        0,
        4, 4       -- Make it 2x bigger so you can see it
    )

    love.graphics.draw(
        characterspritesheet1,
        snakeheadsprite,
        (snakeSegments[1].x-1) * cellSize,
        (snakeSegments[1].y-1) * cellSize,
        0,
        cellSize / 16,
        cellSize / 32
    )


    for segmentIndex = 2, #snakeSegments do
        local segment = snakeSegments[segmentIndex]
        love.graphics.setColor(148/255, 232/255, 240/255)
        love.graphics.rectangle(
            'fill',
        (segment.x - 1) * cellSize,
        (segment.y - 1) * cellSize,
        cellSize - 1,
        cellSize - 1
        )
    love.graphics.print("Time Left: " .. math.ceil(countdownTime), 10, 10)
    end
end