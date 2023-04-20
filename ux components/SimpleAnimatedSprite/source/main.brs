Library "v30/bslDefender.brs"

Function Main() as void
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
    compositor = CreateObject("roCompositor")
    compositor.SetDrawTo(screen, &h000000FF)
    clock = CreateObject("roTimespan")
    clock.Mark()
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    codes = bslUniversalControlEventCodes()
    
    sprite = compositor.NewAnimatedSprite(450, 225, bitmapset.animations.animated_sprite)
    speed = 1000
    while true    
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent") 'Press the right remote key to speed up, left remote key to slow down
            id = event.GetInt()
            if (id = codes.BUTTON_LEFT_PRESSED)
                speed = speed + 100
                if (speed > 5000)
                    speed = 5000
                endif
            else if (id = codes.BUTTON_RIGHT_PRESSED)
                speed = speed - 100
                if (speed < 100)
                    speed = 100
                endif            
            endif
            
        else if (event = invalid)
                ticks = clock.TotalMilliseconds()
            if (ticks > speed)
                compositor.AnimationTick(ticks)
                compositor.DrawAll()
                screen.SwapBuffers()
                clock.Mark()
            endif
        
        endif
    end while
End Function