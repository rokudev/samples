# Podcast Player Channel
Fully working podcast player channel - accepts an MRSS feed and parses artwork and playlist.

![Podcast Player Channel](https://raw.githubusercontent.com/rokudev/docs/master/images/podcast-player-sample.png)


## Use Case

This sample channel can be used to as an example audio player. It demonstrates how to make create a Roku channel that retrieves audio from RSS feeds and implements it as a working Podcast Channel.

## How to run this sample

* Have your podcast MRSS URL ready [simple feed finder tool](http://itunes.so-nik.com/)
* Download the podcast player channel from our Github account [github.com/rokudev](https://github.com/rokudev/podcast-player-channel)
* [In line 6 on the config.brs file](https://github.com/rokudev/podcast-player-channel/blob/master/source/config.brs#L6), swap out the URL for your podcast stream
* Replace all artwork in the [images directory](https://github.com/rokudev/podcast-player-channel/tree/master/images) with your podcast branding.
* Select all the files and folders and .zip up the package (no containing folder needed)
* Load the application onto your Roku [read the developer setup guide](https://blog.roku.com/developer/2016/02/04/developer-setup-guide/)

## Features

* Showcases an Audio Player UI built in SceneGraph
* Includes example usage of a custom LabelList and a custom playbar
* Uses custom Playbar located at the bottom of the screen
* Demonstrates how to use observer functions to track changing content in a channel
* Demonstrates how to parse a RSS feed and load all data into content nodes
* Demonstrates how to create custom components and wrappers

## Directory Structure
* **Components:** SceneGraph Components
  * `MyLabelList` Custom wrapper class for LabelList to override specific functions. Displays all Podcast Episodes
  * `PodcastScene.xml` Creates all SceneGraph nodes displayed in the UI
  * `PodcastScene.brs` This is the back-end for UI. Tracks and monitors Audio playback, manipulates animations, creates functions for audio controls, changes audio content for current audio, etc.
* **Images:** Contains image assets used in the channel
* **Source:** Contains Main method, RSS Parse method, and Config file.
  * **Main:** Creates Screen to display UI when channel starts and declares all global information in the app.
  * **RSS Parse:** This is a method that takes a RSS feed and parses all the content into content nodes that will be passed to the SceneGraph components
  * **Config:** This is a file that declares information that can be edited by any developer to change the color of text or change the audio content to grab from a different RSS feed.

## Channel Flow
* **Event:** Upon starting the channel, the RSS feed is parsed and all content is passed to the SceneGraph nodes.
* **Event:** The content is loaded into the custom LabelList and all channel artwork is created.
* **User:** The user is presented with a UI with a LabelList that can be scrolled through to play any of the podcast content.
* **Event:** Upon choosing an episode in the LabelList the content is played and the audio begins to start.
* **User:** The user can use the trickplay functions on the controller to skip, pause, or rewind audio.
