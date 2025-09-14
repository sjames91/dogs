-- Particle and Visual Effects System
local config = require("game_config")

local Effects = {}

-- Internal particle storage
local particles = {}

-- Initialize effects system
function Effects.init()
    particles = {}
end

-- Reset all effects
function Effects.reset()
    particles = {}
end

-- Update all particles
function Effects.update(dt)
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
end

-- Create a particle burst at specific position
function Effects.createBurst(x, y, particleCount, speedMin, speedMax)
    particleCount = particleCount or config.PARTICLE_COUNT
    speedMin = speedMin or config.PARTICLE_SPEED_MIN
    speedMax = speedMax or config.PARTICLE_SPEED_MAX
    
    -- Create particles in different directions
    for j = 1, particleCount do
        local angle = (j / particleCount) * math.pi * 2
        local speed = love.math.random(speedMin, speedMax)
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            timer = config.TIMERS.PARTICLE_LIFETIME,
            maxTimer = config.TIMERS.PARTICLE_LIFETIME
        })
    end
end

-- Create gold apple effect at specific grid position
function Effects.createGoldAppleEffect(gridX, gridY, offsetX, offsetY, cellSize)
    local centerX = (gridX-1) * cellSize + offsetX + cellSize/2
    local centerY = (gridY-1) * cellSize + offsetY + cellSize/2
    
    Effects.createBurst(centerX, centerY, 12, 100, 200)
end

-- Get particles for rendering (read-only access)
function Effects.getParticles()
    return particles
end

-- Get particle count for debugging
function Effects.getParticleCount()
    return #particles
end

return Effects