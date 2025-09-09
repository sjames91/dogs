-- game loop
function _init()
    map_setup()
    make_player()
end

function _update()
    local player_moved = move_player()
    if player_moved then
        camera_map()
    end
end

function _draw()   
    cls()
    draw_map()
    draw_player()
end