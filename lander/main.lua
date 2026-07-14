function update_ship()

    local safe_speed = 0.90

    if not ship.alive or ship.landed then
        return
    end

    -- left thruster
    if btn(0) then
        ship.dx -= side_thrust
    end

    -- right thruster
    if btn(1) then
        ship.dx += side_thrust
    end

    -- engine spool-up
    if btn(2) and ship.fuel > 0 then
        ship.engine += 0.04
        ship.fuel -= 1
    else
        ship.engine -= 0.03
    end

    ship.fuel = max(ship.fuel, 0)

    -- keep engine between 0 and 1
    ship.engine = mid(0, ship.engine, 1)

    -- apply engine thrust
    ship.dy -= main_thrust * ship.engine

    -- gravity
    ship.dy += gravity

    -- movement
    ship.x += ship.dx
    ship.y += ship.dy

    -- screen boundaries
    if ship.x < 0 then
        ship.x = 0
        ship.dx = 0
    end

    if ship.x > 120 then
        ship.x = 120
        ship.dx = 0
    end

    -- ship center
    local ship_center = ship.x + 4

    -- check if over landing pad
    local on_pad =
        ship_center >= pad.x and
        ship_center <= pad.x + pad.w

-- landing pad collision
    if on_pad and ship.y + 8 >= pad.y then

        ship.impact_speed = abs(ship.dy)

    if ship.impact_speed <= safe_speed then
        ship.landed = true
        ship.y = pad.y - 8
        ship.dy = 0
    else
        ship.alive = false
    end

end

---score calculation
function calculate_score()

    local fuel_score = flr(ship.fuel)
    local landing_score = max(0,
        flr((1 - ship.impact_speed) * 100)
    )

    return fuel_score + landing_score

end

   


-- ground collision
if not on_pad and ship.y + 8 >= 120 then

    ship.impact_speed = abs(ship.dy)
    ship.alive = false

end

    -- damping
    ship.dx *= 0.98
    ship.dy *= 0.99

end


function reset_ship()
    ship.x = 64
    ship.y = 20

    ship.dx = rnd(2) - 1
    ship.dy = rnd(0.5)

    ship.engine = 0
    ship.fuel = 100
    ship.impact_speed = 0

    ship.alive = true
    ship.landed = false

    pad.x = flr(rnd(104))
    
end

------------------------------

----------   INIT    ---------

------------------------------



function _init()

    ship = {

    -- position
    x = 64,
    y = 20,

    -- velocity
    dx = rnd(2) - 1,
    dy = rnd(0.5),

    -- state
    alive = true,
    landed = false,

    -- engine
    engine = 0,
    fuel = 100,

    -- debug
    impact_speed = 0,

    --message
    message = ""
}

    pad = {
        x = flr(rnd(104)),
        y = 118,
        w = 24,
        h = 2
    }


    gravity = 0.05--0.05
    main_thrust = 0.15 --0.12
    side_thrust = 0.07

    debug_mode = false
    debug_presses = 0
    debug_timer = 0

end

------------------------------

----------   DRAW    ---------

------------------------------

function _draw()

    cls(1)
    map(0,0,0,0,16,16)

    
    -- ship
  spr(1, ship.x, ship.y)

  -- engine flame

    if btn(2) and ship.fuel > 0 then
    spr(3, ship.x, ship.y + 1)
    end

    if btn(0) and ship.fuel > 0 then
    spr(6, ship.x + 4, ship.y + 2)
    end

    if btn(1) and ship.fuel > 0 then
    spr(5, ship.x - 4, ship.y + 2)
    end
     



    -- landing pad
    rectfill(
        pad.x,
        pad.y,
        pad.x + pad.w,
        pad.y + pad.h,
        11
    )

 

    -- debug

    if debug_mode then
    print("dx:" .. ship.dx, 0, 0, 7)
    print("dy:" .. ship.dy, 0, 8, 7)
    print ("eng" .. ship.engine,0,16,7)
    print("impact:"..ship.impact_speed, 0, 24, 7)
    print("debug mode", 49, 10, 7)
    print("fuel:" .. flr(ship.fuel), 0, 32, 7)
    end

  -- landing/crash messages
if ship.landed then

    print("successful landing!", 20, 40, 11)
    print("Score: "..calculate_score(), 20, 60, 7)

    if ship.impact_speed > 0.65 then
        print("hard landing", 20, 50, 8)

    elseif ship.impact_speed > 0.35 and ship.impact_speed <= 0.65 then
        print("good landing", 20, 50, 10)

    else
        print("superb landing", 20, 50, 11)
    end

end

if not ship.alive then
    print("crashed!", 45, 40, 8)
    spr(17, ship.x, ship.y)
end
end

------------------------------

--------   Update    ---------

------------------------------

function _update()

    update_ship()
    if not ship.alive or ship.landed then
        if btnp(4) then
            reset_ship()
        end
    end

    if debug_timer > 0 then
        debug_timer -= 1
    end

if btnp(5) then

    if debug_timer <= 0 then
        debug_presses = 0
    end

    debug_presses += 1
    debug_timer = 30

    if debug_presses >= 5 then
        debug_mode = not debug_mode
        debug_presses = 0
    end

end

end
