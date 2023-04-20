Library "v30/bslDefender.brs"

Function Main() as void
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
    ballsize = bitmapset.extrainfo.ballsize.ToInt()
    compositor = CreateObject("roCompositor")
    compositor.SetDrawTo(screen, &h000000FF)
    screenWidth = screen.GetWidth()
    screenHeight= screen.GetHeight()
    clock = CreateObject("roTimespan")
    clock.Mark()
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    codes = bslUniversalControlEventCodes()
    sprites = []
    balls = []
    balls[0] = bitmapset.animations.animated_3ball
    balls[1] = bitmapset.animations.animated_4ball
    balls[2] = bitmapset.animations.animated_5ball
    balls[3] = bitmapset.animations.animated_6ball
    balls[4] = bitmapset.animations.animated_8ball
    
    spriteCount = 0
    sprites[0] = compositor.NewAnimatedSprite(Rnd(screenWidth-ballSize), Rnd(screenHeight-ballSize), balls[0])    
    sprites[0].SetData( {dx: Rnd(20)+10, dy: Rnd(20)+10, index: spriteCount} )

    speed = 100
    while true
        for each sprite in sprites
            sprite.SetMemberFlags(1)
        end for
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent") 'Press the right remote key to speed up, left remote key to slow down
            id = event.GetInt()
            if ((id = codes.BUTTON_RIGHT_PRESSED) AND (spriteCount <= 5)) 'Add a sprite
                spriteCount = spriteCount + 1
                sprites[spriteCount] = compositor.NewAnimatedSprite(Rnd(screenWidth-ballSize), Rnd(screenHeight-ballSize), balls[spriteCount])                
                sprites[spriteCount].SetData( {dx: Rnd(20)+10, dy: Rnd(20)+10, index: spriteCount} )
            else if (id = codes.BUTTON_LEFT_PRESSED)
                wait(0, port)
            endif
            
        else if (event = invalid)
                ticks = clock.TotalMilliseconds()
            if (ticks > speed)
                for each sprite in sprites
                    dx = sprite.GetData().dx
                    dy = sprite.GetData().dy
                    sprite.MoveTo( (sprite.GetX() + dx), (sprite.GetY() + dy) )
                    collidingSprite = sprite.CheckCollision()
                    if (collidingSprite <> invalid)
                        doCollision(sprite, collidingSprite, sprites)
                    endif                    
                end for
                
                sprites = checkEdgeCollisions(sprites, screenWidth, screenHeight, ballsize)
                compositor.AnimationTick(ticks)
                compositor.DrawAll()
                screen.SwapBuffers()
                clock.Mark()
            endif
        
        endif
    end while
End Function

Function checkEdgeCollisions(sprites as object, screenWidth as integer, screenHeight as integer, ballsize as integer) as object
    for each sprite in sprites
        x = sprite.GetX()
        y = sprite.GetY()
        i = sprite.GetData().index
        deltaX = sprite.GetData().dx
        deltaY = sprite.GetData().dy
        if ((x + ballsize) > screenWidth)
            x = screenWidth - ballsize
            if (deltaX > 0)
                deltaX = -deltaX
            endif
            sprite.SetData( {dx: deltaX, dy: deltaY, index: i} )
        endif

        if (x < 0)
            'x = -x
            x = 0
            if (deltaX < 0)
                deltaX = -deltaX
            endif
            sprite.SetData( {dx: deltaX, dy: deltaY, index: i} )
        endif
        
        if ((y + ballsize) > screenHeight)
            y = screenHeight - ballSize
            if (deltaY > 0)
                deltaY = -deltaY
            endif
            sprite.SetData( {dx: deltaX, dy: deltaY, index: i} )
        endif

        if (y < 0)
            'y = -y
            y = 0
            if (deltaY < 0)
                deltaY = -deltaY
            endif
            'deltaY = -deltaY
            sprite.SetData( {dx: deltaX, dy: deltaY, index: i} )
        endif
        sprite.MoveOffset(deltaX, deltaY)
    end for
    return sprites
End Function

Function doCollision(sprite0 as object, sprite1 as object, sprites as object) as object
    index0 = sprite0.GetData().index
    index1 = sprite1.GetData().index
    dx = sprite1.GetX() - sprite0.GetX()
    dy = sprite1.GetY() - sprite0.GetY()
    if (dx > 0)
        angle = atn(dy / dx)
    else
        angle = 1.5708
    endif
    fSin = sin(angle)
    fCos = cos(angle)
    
    pos0 = {}
    pos0.x = 0
    pos0.y = 0
    pos1 = rotate(dx, dy, fSin, fCos, true)
    
    vel0 = rotate(sprite0.GetData().dx, sprite0.GetData().dy, fSin, fCos, true)
    vel1 = rotate(sprite1.GetData().dx, sprite1.GetData().dy, fSin, fCos, true)
    
    'collision reaction
    vxTotal = vel0.x - vel1.x
    vel0.x = vel1.x
    vel1.x = vxTotal + vel0.x

    'update position
    pos0.x = pos0.x + vel0.x
    pos1.x = pos1.x + vel1.x

    'rotate positions back
    pos0F = rotate(pos0.x, pos0.y, fSin, fCos, false)
    pos1F = rotate(pos1.x, pos1.y, fSin, fCos, false)

    'adjust positions to actual screen positions
    'sprite1.MoveOffset(pos1F.x, pos1F.y)
    'sprite0.MoveOffset(pos0F.x, pos0F.y)
    sprites[index0].MoveOffset(pos0F.x, pos0F.y)    
    sprites[index1].MoveOffset(pos1F.x, pos1F.y)
    'rotate velocities back
    vel0F = rotate(vel0.x, vel0.y, fSin, fCos, false)
    vel1F = rotate(vel1.x, vel1.y, fSin, fCos, false)
    sprites[index0].SetData( {dx: vel0F.x, dy: vel0F.y, index: index0} )
    sprites[index1].SetData( {dx: vel1F.x, dy: vel1F.y, index: index1} )
    sprites[index0].SetMemberFlags(0)
    sprites[index1].SetMemberFlags(0)    
    return sprites
    
End Function

Function rotate(x as float, y as float, fSin as float, fCos as float, reverse as boolean) as object
    res = {}
    if (reverse)
        res.x = (x * fCos + y * fSin)
        res.y = (y * fCos - x * fSin)
    else
        res.x = (x * fCos - y * fSin)
        res.y = (y * fCos + x * fSin)    
    endif
    return res
End Function