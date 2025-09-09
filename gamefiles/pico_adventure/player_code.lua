function make_player()
    p={}
    p.x=55/8
    p.y=64/8
    p.sprite=16
    p.keys=0
    p.cheese=false
    p.move_timer=0  -- add timer for movement delay
end

function draw_player()
    spr(p.sprite,p.x*8,p.y*8)
end

function move_player()
    p.move_timer = p.move_timer + 1
    local moved = false
    
    -- only move every 3-4 frames to slow down movement
    if p.move_timer >= 3 then
        p.move_timer = 0
        if btn(0) then p.x = p.x - 1/8; moved = true end
        if btn(1) then p.x = p.x + 1/8; moved = true end
        if btn(2) then p.y = p.y - 1/8; moved = true end
        if btn(3) then p.y = p.y + 1/8; moved = true end
    end
    
    return moved
end