## FloatFieldInterpolator Markup

**Interpolator Node Reference:** **FloatFieldInterpolator**

In this example, we'll use a **FloatFieldInterpolator** node to animate the `opacity` field of a **Poster** node, causing it to fade in and out of visibility. We'll go ahead and use the same **Poster** node definition we used in [**Renderable Node Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes)previously. The following shows the XML **Animation** node and **FloatFieldInterpolator** child node definitions for this:

```
<Animation 
  id = "exampleFloatAnimation" 
  duration = "5" 
  easeFunction = "linear" >

  <FloatFieldInterpolator 
    key = "[ 0.0, 0.5, 1.0 ]" 
    keyValue = "[ 1.0, 0.0, 1.0 ]" 
    fieldToInterp = "examplePoster.opacity" />

</Animation>
```

We've kept this example simple by using the same `duration` and `key` field definitions as in the previous **Vector2DFieldInterpolator** example. This means that the animation will again last five seconds, and be divided into three parts: a beginning at 0 seconds (`key` value 0.0), a middle at 2.5 seconds (`key` value 0.5), and an end at five seconds (`key` value 1.0). Note that this causes the `examplePoster` to gradually disappear from the display screen, be fully invisible at 2.5 seconds, then gradually reappear until it is completely visible at five seconds. And again, because the animation `repeat` field was set to `true`, this happens over and over and over again... 

![img](https://sdkdocs.roku.com/download/attachments/1606015/animfloatdoc.jpg?version=2&modificationDate=1472836119453&api=v2)