' Copyright (c) 2025 Roku, Inc. All rights reserved.

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
