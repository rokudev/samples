Library "v30/bslDefender.brs"
Function Main() as integer
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
    compositor = CreateObject("roCompositor")
    codes = bslUniversalControlEventCodes()
    clock = CreateObject("roTimespan")
    'Create an array to hold the sprites
    sprites = CreateObject("roArray", 10, true)
    'Create an array to hold the snowflake frame images
    snowflakes = CreateObject("roArray", 3, false)
    snowflakes[0] = bitmapset.animations.animated_snowflake1
    snowflakes[1] = bitmapset.animations.animated_snowflake2
    snowflakes[2] = bitmapset.animations.animated_snowflake3

    screenHeight = screen.GetHeight()
    screenWidth = screen.GetWidth()
    
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    eventWait = 100
	directionY = 20
    compositor.SetDrawTo(screen, 0)
    background = bitmapset.regions.background
    compositor.NewSprite(0, 0, background)
    newSprites = CreateObject("roArray", 10, true)    
    sprites = AddSprite(sprites, snowflakes, compositor)
    clock.Mark()
    while true
        event = port.GetMessage()
        if (event = invalid)
            ticks = clock.TotalMilliseconds()
            if (ticks> 200)
                sprites = AddSprite(sprites, snowflakes, compositor)
                compositor.AnimationTick(ticks)
                compositor.DrawAll()
                screen.SwapBuffers()
                clock.Mark()
    
                for each sprite in sprites
                    dirFlag = Rnd(2) - 1
                    if (dirFlag > 0)
                        directionX = Rnd(10) + 10
                    else
                        directionX = -(Rnd(10) + 10)
                    endif
        
                    x = sprite.GetX() + directionX
                    y = sprite.GetY() + Rnd(30) + 20
                    if (y < screenHeight)
                        newSprites.Push( sprite )
                        sprite.MoveTo(x, y)
                    else
                        doStop = true
                    endif
                end for

                'Remove any sprites that are off screen
                sprites.Clear()
                sprites.Append(newSprites)
                newSprites.Clear()
            endif
        endif        
    end while
End Function

'Create the sprites used by the application
Function AddSprite(sprites as object, snowflakes as object, compositor as object) as object    
    'Randomly select the snowflake to use with each sprite
    x = Rnd(1180)
    newSprite = compositor.NewAnimatedSprite(x, 0, snowflakes[Rnd(3)-1])
    sprites.Push(newSprite)
    return sprites    
End Function
