' Copyright (c) 2025 Roku, Inc. All rights reserved.

sub Init()
    my_task = m.top.FindNode("myTask")
    my_task.ObserveField("done", "OnTaskDone")
    my_task.control = "run"
end sub

sub OnTaskDone()
    tracer = CreateObject("roPerfetto")
    flow_id = 42 ' flow id must match the one used to start the flow
    tracer.terminateFlow(flow_id, "task_done")
end sub
