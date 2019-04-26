## ColorFieldInterpolator Markup

** Interpolator Node Reference: ColorFieldInterpolator**

For this final **Animation** node interpolator example, we'll change the color of a rectangle. To do this, we must use the **ColorFieldInterpolator** node, which can change the `color` field of a target node over the time of the animation specified in the **Animation** node `duration` field. Once again, to keep it simple, we'll use the same `duration`, and `key` field definitions used in the previous interpolator examples, and use the same **Rectangle** node markup from [**Renderable Node Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes):

```
<Animation `
<Animation 
  id = "exampleColorAnimation" 
  duration = "5" 
  easeFunction = "linear" >

  <ColorFieldInterpolator 
    key = "[ 0.0, 0.5, 1.0 ]" 
    keyValue = "[ 0x1010EBFF, 0x10101FFF, 0x1010EBFF ]" 
    fieldToInterp = "exampleRectangle.color" />

</Animation>
```

Because we used many of the same field definitions as the previous interpolator examples, it should be clear that the only difference here is that the animation changes the `color` field of the target `exampleRectangle` rectangle, so it changes the rectangle color rather than moving or fading it. The color changes from blue (0x1010EBFF) at 0 seconds, to black (actually a very dark shade of blue, 0x10101FFF) at 2.5 seconds, and back to blue at five seconds.

![img](https://sdkdocs.roku.com/download/attachments/1606015/animcolordoc.jpg?version=2&modificationDate=1472836165733&api=v2)