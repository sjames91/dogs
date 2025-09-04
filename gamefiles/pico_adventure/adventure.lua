-- game loop
current_map = 1

function _init()
    map_setup()
    make_player()
end

function _update()
    move_player()

        if p.x<16 and current_map == 1 then p.x=0 end
    elseif p.x < 0 then p.x=32 
    end
end

function _draw()
    cls()

    if current_map == 1 and
    p.x>16 then
    draw_map()
    elseif current_map == 2 and
    p.x<16 then
    draw_map_2
    end

    draw_player()
end