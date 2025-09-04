-- game loop

function _init()
    map_setup()
    make_player()
end

function _update()	
 move_player()
end

function _draw()
    cls()
    
    

    if p.x<16 then
    draw_map()
    elseif p.x>16 then
    draw_map_2()
    end
    
    draw_player()
    
    print(p.x,64,64)
end