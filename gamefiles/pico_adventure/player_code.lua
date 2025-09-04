function make_player()
    p={}
    p.x=10
    p.y=11
    p.sprite=16
    p.keys=0
    p.cheese=false
end

function draw_player()
    spr(p.sprite,p.x*8,p.y*8)
end

function move_player()
    if btn(0) then p.x = p.x - 1/8 end
    if btn(1) then p.x = p.x + 1/8 end
    if btn(2) then p.y = p.y - 1/8 end
    if btn(3) then p.y = p.y + 1/8 end


end