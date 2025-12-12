# Perfetto Custom Events

This sample shows how to generate various custom Perfetto events from an app.

## Instantaneous Events

Instantaneous Events are the simplest. They have no duration, but can have additonal paramaters associated with them. In `main.brs` the app generates two of these events, one with parameters and one without.

```
    ' instantaneous events
    tracer.instantEvent("instantaneous_event")
    ' instantaneous event with parameters
    tracer.instantEvent("instantaneous_event_params", {p1: 42, p2: "hello world"})
```

## Duration Events

Duration events have a beginning and an end. In addition, you can nest them so that they appear as a stack in the Perfetto viewer. In `main.brs` the app generates a series of three nested duration events.

```
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
```

# Scoped Events

Scoped events are similar to duration events, except that you do not end them explicitly. They end automatically when the returned object goes out of scope. In `main.brs` the app defines a function `DoScopedEvents()` that demonstrates this mechanism.

```
sub DoScopedEvent()
    tracer = CreateObject("roPerfetto")
    scoped_event = tracer.createScopedEvent("scoped_event")
    sleep(500)
    ' the event will end automatically when scoped_event goes out of scope
end sub 
```

## Flow Events

Flow events allow you to connect a series of events. In the Perfetto viewer they will be shown with arrows between them. In `MyTask.brs` the app generates a series of flow events starting in its `Init()` and continuing in `MyTaskFunction()`. Then, in `MyScene.brs` the app terminates the flow in the observer function `OnTaskDone()`

```
sub Init()
    tracer = CreateObject("roPerfetto")
    ' flow id can be any integer value
    ' it is used to correlate flow events, so it's important to use the same id
    ' for all events that are part of the same flow
    flow_id = 42 
    tracer.flowEvent(flow_id, "task_init")

    m.top.functionName = "MyTaskFunction"
end sub

sub MyTaskFunction()
    tracer = CreateObject("roPerfetto")
    flow_id = 42 ' flow id must match the one used to start the flow
    tracer.flowEvent(flow_id, "task_function")

    sleep(50) ' simulate work being done

    m.top.done = true
end sub
```
```
sub OnTaskDone()
    tracer = CreateObject("roPerfetto")
    flow_id = 42 ' flow id must match the one used to start the flow
    tracer.terminateFlow(flow_id, "task_done")
end sub
```