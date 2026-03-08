' Copyright (c) 2025 Roku, Inc. All rights reserved.

sub Main(args)
    ' you can reuse a single roPerfetto object to record multiple events
    tracer = CreateObject("roPerfetto")

    ' instantaneous events
    tracer.instantEvent("instantaneous_event")
    ' instantaneous event with parameters
    tracer.instantEvent("instantaneous_event_params", {p1: 42, p2: "hello world"})

    ' duration events
    tracer.beginEvent("duration_event")
    sleep(500)
    ' events can be nested and will be shwon as a stack in the Perfetto viewer
    tracer.beginEvent("duration_subevent_1")
    sleep(500)
    tracer.beginEvent("duration_subevent_2")
    sleep(500)
    ' it is important that the number of endEvent() calls matches the number of beginEvent() calls
    tracer.endEvent()
    sleep(500)
    tracer.endEvent()
    tracer.endEvent()

    ' scoped events
    DoScopedEvent()

    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    scene = screen.CreateScene("MyScene")
    screen.show()

    while(true)
        msg = wait(0, port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

sub DoScopedEvent()
    tracer = CreateObject("roPerfetto")
    scoped_event = tracer.createScopedEvent("scoped_event")
    sleep(500)
    ' the event will end automatically when scoped_event goes out of scope
end sub 
