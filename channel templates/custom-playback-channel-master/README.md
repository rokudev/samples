# Custom Playback Channel
SceneGraph Roku SDK2 example of how to display video with a playlist of content

![Custom Playback Graphic](https://raw.githubusercontent.com/rokudev/docs/c8dd67bb38a53eb57948c4f65237954bb22e0014/images/custom-playback.jpg)

## Use Cases
If you want to have a channel that plays a video and allows the user to browse other content on a list that's displayed without stopping the video.

## How to run this sample
- The file to upload/side-load on your Roku device is ```custom-playback-channel.zip```, located in the ```sample channels``` repository: https://github.com/rokudev/sample-channels/blob/master/custom-playback-channel.zip
- If you have trouble side-loading the channel, follow the developer set-up guide here for a quick guide on how to do so: https://blog.roku.com/developer/2016/02/04/developer-setup-guide/
- Alternatively, open up this project in Eclipse or Atom and use the corresponding plugin/package to export/deploy the channel.
  - Eclipse plugin documentation in the SDK docs: https://sdkdocs.roku.com/display/sdkdoc/Eclipse+Plugin+Guide 
  - The blog post for the Eclipse plugin: https://blog.roku.com/developer/2016/04/20/roku-eclipse-plugin/ 
  - Roku Deploy package for Atom: https://atom.io/packages/roku-deploy 

## FAQ 
- How do I make the list visible on channel start?
    - Set the visible field to true for the labellist in MainScene.xml. (e.g. ```visible="true"```)
- How do I set the opacity of the list? 
    - Set the opacity field of the labellist in MainScene.xml. (e.g. ```opacity=".5"```)

## Issues or Feature Requests
- Please submit an issue on this repository or post on the Roku forums about this channel. 
- To create an issue: https://help.github.com/articles/creating-an-issue/ 
- The Roku forum: https://forums.roku.com/
- If you have features that you have implemented and want to contribute to this channel's development, submit a pull request! 
- To create a pull request: https://help.github.com/articles/creating-a-pull-request/
- What is a pull request? https://help.github.com/articles/about-pull-requests/ 
