#Rotated Renderable Nodes Markup

Roku SceneGraph allows you to rotate renderable nodes and groups of nodes by arbitrary amounts, depending on the Roku Player (some Roku Players may not allow arbitrary rotation amounts, and some many not allow rotation of any or all of the renderable node classes).

This sample  rotates the same size and shape rectangle shown in [**Rectangle Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes) by 90 degrees. To do this, we add two fields to the **Rectangle** node markup, one to specify the center about which the rotation will occur, the other to actually rotate the node:

```
<Rectangle 
  id = "examplerotatedRectangle" 
  width = "512" 
  height = "288" 
  scaleRotateCenter = "[ 256.0, 144.0 ]" 
  rotation = "1.5707963268" 
  color = "0x1010EBFF" />
```

We set the scaleRotateCenter  field value to [256.0,144.0] to make the center of the 512x288 rectangle the center of rotation. Then we actually rotate the rectangle by setting the `rotation` field value to 1.5707963268, which is a close enough approximation in radians to 90 degrees (you probably could make it even closer!):

![img](https://sdkdocs.roku.com/download/attachments/1606014/rectanglerotdoc.jpg?version=2&modificationDate=1472835417457&api=v2)

Note that we use slightly different code in the **init()** function to center this example in the HD UI resolution display screen. Instead of the [**boundingRect()**](https://developer.roku.com/docs/references/api-index/brightscript/interfaces/ifsgnodeboundingrect.md#boundingrect-as-dynamic) method we use for almost all other examples in this tutorial, we use the related [**localBoundingRect()**](https://developer.roku.com/docs/references/api-index/brightscript/interfaces/ifsgnodeboundingrect.md#localboundingrect-as-dynamic) method:

```
examplelrect = example.localBoundingRect()
centerx = (1280 - examplelrect.width) / 2
centery = (720 - examplelrect.height) / 2
example.translation = [ centerx, centery ]RER
```

Because the rectangle translation coordinates and bounding rectangle dimensions rotate along with the rectangle, the **localBoundingRect()** method is needed to find the new values.