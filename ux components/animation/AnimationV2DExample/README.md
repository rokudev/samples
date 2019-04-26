# Vector2DFieldInterpolator Markup

 **Interpolator Node Reference: Vector2DFieldInterpolator**

In this example, we'll use a **Vector2DFieldInterpolator** node to animate the `translation` field of a **Rectangle** node, causing it to move around the screen. If you look at the `animationv2dscene.xml` file in the example application package, you'll note we are using a similar **Rectangle** node definition to some we used in previous tutorial examples, specifically the big blue rectangle in [**Z-Order/Parent-Child Markup**](https://github.com/rokudev/samples/blob/master/ux%20components/screen%20elements/z-order_parent_child/ZORenderablesExample.zip):

```
<Rectangle `
`  id = "movingRectangle" `
`  width = "720" `
`  height = "240" `
`  color = "0x1010EBFF" />
```

But we're defining it as a child node of a larger **Rectangle** node to set the boundaries of the animation. We make this parent **Rectangle** node invisible by setting the alpha channel to 0x00:

**Vector 2D Animation Example**

```
<children>
 
  <Rectangle
    id = "exampleRectangle"
    width = "900"
    height = "330"
    color = "0x10101000" >
 
    <Rectangle
      id = "movingRectangle"
      width = "720"
      height = "240"
      color = "0x1010EBFF" />
 
  </Rectangle>
 
  <Animation
    id = "exampleVector2DAnimation"
    duration = "5"
    easeFunction = "linear" >
 
    <Vector2DFieldInterpolator
      key = "[ 0.0, 0.5, 1.0 ]"
      keyValue = "[ [0.0,0.0], [180.0,90.0], [0.0,0.0] ]"
      fieldToInterp = "movingRectangle.translation" />
 
  </Animation>
 
</children>
```

We're actually only using this parent **Rectangle** node to establish the dimension limits of the animation; it is not visible in the example, but allows us to center the moving rectangle at the mid-point of the animation.

This all might look a little confusing so let's break it down piece by piece:

- We added an ID for the **Animation** node to target the node by BrightScript code in the **init()** function:

```
id = "exampleVector2DAnimation"
```

- We set the duration of the animation to five seconds:

```
duration = "5"
```

- We are using the most typical "linear" definition of the `easeFunction` field, which is actually the default animation ease function:

```
easeFunction = "linear"
```

- In the **Vector2DFieldInterpolator** child node, we have two fields with arrays of values that must have the same number of values:

```
key = "[ 0.0, 0.5, 1.0 ]" ``keyValue = "[ [0.0,0.0], [180.0,90.0], [0.0,0.0] ]"
```

- the `key` field array contains the fractional values of the five second duration of the animation where the field value specified by the corresponding `keyValue` array is set; for this animation there are three key values which basically divide the animation into three parts, a beginning (0.0), a middle (0.5), and an end (1.0) 

  

- the `keyValue` field array contains the values of the **Rectangle** node `translation` field that will be set at the corresponding fractional value in the `key` array, to position the rectangle at the specified X,Y position on the display screen 

  

- The `fieldToInterp` field then defines which of the **Rectangle** node fields to animate; in this case it is the `translation` field of the `movingRectangle` node as identified by its ID field:

```
fieldToInterp = "movingRectangle.translation"
```

Now to start the animation, we have to set the `control` field of the **Animation** node object to `play` using BrightScript in the **init()** function, where we also set the `repeat` field to true to have the animation to repeat (endlessly) after completing:

```
m.vector2danimation = m.top.FindNode("exampleVector2DAnimation")`
`m.vector2danimation.repeat = true`
`m.vector2danimation.control = "start"
```

The following shows the position of the text on the display screen correlated with the `duration` field time, the `key` field fractional portion of the animation, and the `keyValue` position of the moving rectangle:

![img](https://sdkdocs.roku.com/download/attachments/1606015/animv2ddoc14pt.jpg?version=1&modificationDate=1472829249907&api=v2)

It can take a little while to correlate the definitions of these fields with the movement of the rectangle on the screen, so take some time and watch it move back and forth...and back and forth... 