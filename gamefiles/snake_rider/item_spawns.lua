-- apples
local apple_spawns = {}

function apple_spawns.spawnApple()
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

function apple_spawns.spawnGoldApple()
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
            timer = love.math.random(8, 12), -- Gold apples last longer
            gold = true -- Mark as gold apple
        }
        table.insert(apples, newApple)
    end
end
return apple_spawns