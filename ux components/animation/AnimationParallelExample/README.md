## ParallelAnimation Markup

**Node Class Reference:** **ParallelAnimation**

The **ParallelAnimation** node class is very similar to the **SequentialAnimation** node class, in that it is a parent node to several child animation nodes. But instead of running each child animation node in sequence, the child animation nodes are run at the same time, in parallel.

Let's animate the same three rectangles in [**SequentialAnimation Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/animation) to move the same way, but this time in parallel:

**Parallel Animation Example**

```
<children>
 
  <Group id = "animatedRectangles" >
 
    <Rectangle
      id = "lowestRectangle"
      width = "180"
      height = "60"
      color = "0xEB1010FF" />
 
    <Rectangle
      id = "middleRectangle"
      width = "360"
      height = "120"
      color = "0x10EB10FF" />
 
    <Rectangle
      id = "highestRectangle"
      translation = "[ 180.0, 90.0 ]"
      width = "720"
      height = "240"
      color = "0x1010EBFF" />
 
    <ParallelAnimation id = "exampleParallelAnimation" >
 
      <Animation
        duration = "5"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[0.0, 0.5, 1.0]"
          keyValue = "[ [0.0,0.0], [60.0,30.0], [0.0,0.0] ]"
          fieldToInterp = "middleRectangle.translation" />
 
      </Animation>
 
      <Animation
        duration = "5"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[0.0, 0.5, 1.0]"
          keyValue = "[ [0.0,0.0], [180.0,90.0], [0.0,0.0] ]"
          fieldToInterp = "highestRectangle.translation" />
 
      </Animation>
 
    </ParallelAnimation>
 
  </Group >
 
</children>
```

Again we set the boundary of the animation at its furthest point by setting the `translation` field of the big blue rectangle. And again we define a parent **ParallelAnimation** node with several child animation nodes. The child animation nodes differ from `AnimationSequentialExample.zip` in that they have an entire set of `keyValue` field values, to move the rectangles to their furthermost position, then back to their starting position.

And again the parallel animation is started in the **init()** function:

```
m.exampleparallelanimation = m.top.FindNode("exampleParallelAnimation")`
m.exampleparallelanimation.repeat = true`
m.exampleparallelanimation.control = "start"
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/1606015/animparalleldoc.jpg?version=2&modificationDate=1472836275113&api=v2)