map_x = 0
map_y = 0
current_map = 1

function map_setup()
end

function draw_map()
   if current_map == 1 then map(map_x,map_y,0,0,16,16) end
end

function camera_map()
    -- center camera on player
    -- convert player position to pixel coordinates and center on screen
    -- round to nearest pixel to avoid sub-pixel jitter
    map_x = flr((p.x * 8) - 64)  -- 64 is half screen width (128/2)
    map_y = flr((p.y * 8) - 64)  -- 64 is half screen height (128/2)
    
    -- optional: add camera bounds to prevent showing area outside the map
    -- map_x = max(0, min(map_x, map_width_in_pixels - 128))
    -- map_y = max(0, min(map_y, map_height_in_pixels - 128))
end