# trickplay-sample-channels
The four samples in this repo demonstrate different ways to generate and incorporate thumbnails for trick play. The samples vary based on whether they use BIF or JPEG files for the thumbnails, whether they use the native or a custom video player, and whether server-side ads are included in the thumbnails. 

BIF is the recommended format for thumbnails on channels that use the firmware’s built-in video player. Therefore, the BIF samples use the native video player. Using the BIF format entails creating the BIF files using the [biftool](https://sdkdocs.roku.com/display/sdkdoc/Trick+Mode+Support#TrickModeSupport-BIFFileCreationusingtheRokuBIFTool), putting the files on a server, and adding the BIF image URLs (sdbifurl and hdbifurl) to a ContentNode that is then passed to a Video node. Both BIF samples demonstrate how to configure the ContentNode and Video nodes.  

The samples with JPEG thumbnails use a custom video player that features custom trick play logic, a progress bar, and a video buffering status loading bar. 

The four samples are summarized as follows:

* [simplevideo-with-bif](/simplevideo-with-bif) uses BIF for trick play thumbnails and does not include ads.

* [RAFSSAI-with-bif](/RAFSSAI-with-bif) uses BIF for trick play thumbnails and includes server-side ads in some of them.

* [simplevideo-with-jpeg](/simplevideo-with-jpeg) uses JPEG files for thumbnails, which are generated using the script [gen-thumbs.sh](/scripts/gen-thumbs.sh) and extracted at constant intervals. A group of five Posters that represent 5-second intervals are used to display the thumbnails.

* [RAFSSAI-with-jpeg](/RAF-SSAI-with-jpeg) is similar to the previous sample, but it is aware of ad pods using metadata from the Roku Advertising Framework and ads are not displayed in the trick play thumbnails.
