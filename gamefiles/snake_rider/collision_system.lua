-- Collision Detection and Scoring System
local GameState = require("game_state")
local Effects = require("effects")

local CollisionSystem = {}

-- Handle collision between snake and items
function CollisionSystem.handleItemCollisions(snake, items, offsetX, offsetY, cellSize)
    local appleIndex, apple = snake:checkAppleCollision(items)
    
    if appleIndex then
        -- Apple was eaten - snake grows, no tail removal needed
        if apple.gold then
            GameState.addApplesEaten(10)
            -- Activate speed boost
            snake:activateSpeedBoost()
            
            -- Create particle effect at apple position
            Effects.createGoldAppleEffect(apple.x, apple.y, offsetX, offsetY, cellSize)
        else
            GameState.addApplesEaten(1)
            -- Extend boost timer if currently boosted
            snake:extendBoost()
        end
        
        -- Update score based on new apples eaten count and current snake length
        GameState.updateScore(GameState.getApplesEaten(), snake:getLength())
        
        -- Remove the eaten apple
        table.remove(items, appleIndex)
        
        return true -- Collision occurred
    elseif snake.movedThisFrame then
        -- Snake moved but didn't eat apple - remove tail to maintain length
        snake:removeTail()
    end
    
    -- Update score based on current snake length (in case snake length changed)
    GameState.updateScore(GameState.getApplesEaten(), snake:getLength())
    
    return false -- No collision
end

-- Check for any collisions and handle them
function CollisionSystem.update(snake, items, offsetX, offsetY, cellSize)
    return CollisionSystem.handleItemCollisions(snake, items, offsetX, offsetY, cellSize)
end

return CollisionSystem