## SequentialAnimation Markup

**Node Class Reference:** [**SequentialAnimation**](https://developer.qa.roku.com/docs/references/api-index/scenegraph/animation-nodes/sequentialanimation.md)

The **SequentialAnimation** node class allows you to group several related animations together to run in sequence, one after another.

Remember how we used the big blue rectangle from previous tutorial examples in [**Vector2DFieldInterpolator Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/animation)? That rectangle was one of three we used to show how Roku SceneGraph implements z-order and parent-child node relationships in [**Z-Order/Parent-Child Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/z-order_parent_child). `AnimationSequentialExample.zip` shows how to move those rectangles so that you see each underlying rectangle in sequence.

**Sequential Animation Example**

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
 
    <SequentialAnimation id = "exampleSequentialAnimation" >
 
      <Animation
        duration = "3"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[ 0.0, 1.0 ]"
          keyValue = "[ [0.0,0.0], [180.0,90.0] ]"
          fieldToInterp = "highestRectangle.translation" />
 
      </Animation>
 
      <Animation
        duration = "3"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[ 0.0, 1.0 ]"
          keyValue = "[ [0.0,0.0], [60.0,30.0] ]"
          fieldToInterp = "middleRectangle.translation" />
 
      </Animation>
 
      <Animation
        duration = "3"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[ 0.0, 1.0 ]"
          keyValue = "[ [60.0,30.0], [0.0,0.0] ]"
          fieldToInterp = "middleRectangle.translation" />
 
      </Animation>
 
      <Animation
        duration = "3"
        easeFunction = "linear" >
 
        <Vector2DFieldInterpolator
          key = "[ 0.0, 1.0 ]"
          keyValue = "[ [180.0,90.0], [0.0,0.0] ]"
          fieldToInterp = "highestRectangle.translation" />
 
      </Animation>
 
    </SequentialAnimation>
 
  </Group>
 
</children>
```

The first step is to define the rectangles, which we've done before. In this case though, we don't define the `translation` field values for the rectangles, except for the last rectangle, since we'll be moving the rectangles by changing the values of the `translation` fields in the animations. But we do set the `translation` field value of the last rectangle, the big blue rectangle, to set the boundary of the animation at its furthest point. This allows us to center the animated rectangles as we've done in all the tutorial examples.

Then we define the `SequentialAnimation` node, which will be the parent node of several child animation nodes that move the rectangles in sequence. We define the parent **SequentialAnimation** node ID as `exampleSequentialAnimation`, so that we can run all the child animation nodes in sequence by setting the `control` field value of this parent node to `start` in the **init()** function. After that, we define the several child animation nodes, to be run in the sequence of their definition. Note that each child animation node is a complete animation with a `duration` field, and a child interpolator node. For example, the first child animation node moves the big blue rectangle from X,Y coordinates 0,0 to 180,90 in three seconds:

```
<Animation 
  duration = "3" 
  easeFunction = "linear" >

  <Vector2DFieldInterpolator 
    key = "[ 0.0, 1.0 ]" 
    keyValue = "[ [0.0,0.0], [180.0,90.0] ]" 
    fieldToInterp = "highestRectangle.translation" />

</Animation>
```

And each successive child animation nodes moves one of the rectangles in a similar manner.

We start the animations in the **init()** function in the usual way, by setting the `control` field value of the parent **SequentialAnimation** node to `start`:

```
m.examplesequentialanimation = m.top.findNode("exampleSequentialAnimation")
m.examplesequentialanimation.repeat = true
m.examplesequentialanimation.control = "start"
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/1606015/animsequencedoc.jpg?version=2&modificationDate=1472836221011&api=v2)