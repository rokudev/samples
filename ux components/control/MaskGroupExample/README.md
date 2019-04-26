## MaskGroup Markup

**Node Class Reference: MaskGroup**

The **MaskGroup** node class allows you to overlay a PNG image on a child node tree, to create alpha channel fading, and other types of image rendering effects, of the child node tree. The pixels of the **MaskGroup** node image are blended with the pixels of the child node tree to create these effects. Typically you might want to use the **MaskGroup** node for a decorative effect such as having a list or grid fade out at the bottom of the screen. You should avoid using a **MaskGroup** node for any purpose that is essential to conveying information to the user, since the **MaskGroup** node only works on certain Roku devices with the OGL (or equivalent) libraries. On Roku devices without the OGL (or equivalent) libraries, the **MaskGroup**node will have no effect.

This example uses a mask image with a smooth grayscale ramp from white to black, from the left to the right of the image. We'll use a simple **Poster** node image as the child node tree to be masked. The example sets the mask image size to the same size as the child image it will overlay in the `masksize` field, and sets the `maskOffset` field to position the mask image completely off the child image to the right.

Then the example uses an animation to move the mask image to the left over the child image, causing the child image to gradually fade out completely from right to left, and then moves the mask back to reverse the effect:

**MaskGroup Animated Example**

```
<?xml version = "1.0" encoding = "utf-8" ?>
 
<!--********** Copyright 2016 Roku Corp.  All Rights Reserved. **********-->
 
<component name = "MaskGroupExample" extends = "Scene" >
 
  <script type="text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      example = m.top.findNode("examplePoster")
 
      examplerect = example.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      example.translation = [ centerx, centery ]
 
      maskgroupanimation = m.top.findNode("MaskGroupAnimation")
      maskgroupanimation.control = "start"
 
      m.top.setFocus(true)
    end sub
 
    ]]>
 
  </script>
 
  <children>
 
    <MaskGroup
      id = "exampleMaskGroup"
      masksize = "[ 512, 288 ]"
      maskOffset = "[ -512, 0 ]"
      maskuri = "pkg:/images/grad_lin_l2r_hd.png" >
 
      <Poster
        id = "examplePoster"
        width = "512"
        height = "288"
        uri = "http://sdktestinglab.com/Tutorial/images/videopg.jpg" />
 
    </MaskGroup>
 
    <Animation
      id = "MaskGroupAnimation"
      duration = "3"
      easeFunction = "linear"
      repeat = "true" >
 
      <Vector2DFieldInterpolator
        id = "interpolator"
        fieldToInterp = "exampleMaskGroup.maskOffset"
        key = "[ 0.0, 0.50, 1.0 ]"
        keyValue = "[ [-512,0], [512,0], [-512,0] ]" />
 
    </Animation>
 
  </children>
 
</component>
```

The example is set to repeat the animation endlessly until it is clear how the **MaskGroup** node works...or you can simply note that the `maskOffset` field controls the amount of the mask image that is overlaid on the child node tree, and the `masksize` field controls the area the mask image will affect. For example, to fade out a large image or node tree at the bottom of a screen, you could use a similar mask image that ramps the grayscale smoothly from top to bottom. Then set the `masksize` field to the width of the entire screen, and about 100 pixels high, and the `maskOffset` field to 100 pixels in the vertical direction. The child image or node tree will fade out starting about 100 pixels from the bottom of the screen.

Or you can watch the `MaskGroupExample.zip` some more:

![img](https://sdkdocs.roku.com/download/attachments/4262849/maskgroupdoc.jpg?version=3&modificationDate=1472836933405&api=v2)
