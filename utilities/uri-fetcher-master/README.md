UriFetcher provides a simple, non-blocking implementation of a basic download manager which is capable of multiple asynchronous URL requests implemented through a long-lived data task.

The core logic is implemented in UriFetcher.brs and UriFetcher.xml with a modular design in mind.


## INTERFACE

The UriFetcher component has one interface Field:<br>

Request - AA with one entry:<br>
Context - node with input and output fields:<br>

1. Parameters - AA for input:<br>

   a. uri - The URI to be fetched, as a string.<br>
   
   b. Other parameters as needed and understood by the UriFetcher code<br>
   
2. Response - AA for output:<br>

   a. Code - The http response code, as an integer<br>
       
   b. Content - The full contents of the fetched file, as an array of arrays<br>

## INSTRUCTIONS

Here are the steps to use the component to fetch a single URI:

1. Create a UriFetcher

2. Create a request context as per the interface field above. Populate the parameter entries as appropriate, particularly the URI entry

3. Observe the newly created context's response field via a function in the client component

4. Set the UriFetcher's request field to an AA containing the context

5. The observing callback method in the client code is invoked when the UriFetcher is done with the request. The context's response field will still contain its original, client-provided parameters AA with the URI, and the response field AA will be populated with the http response code (named code), and the fetched file content (named content)

Here are the steps to use the component to fetch multiple URIs, perhaps even simultaneously:

1. Do all the steps as above for fetching a single URI.

Repeat steps 2-5 as often as is desired without necessarily waiting for previous results before requesting new ones. The requests are queued to the Task built-in to the UriFetcher, they are tracked and asynchronously initiated as soon as they are received by that Task, and the tracked results are dispatched in the order in which the responses are received.

Each client of the URI fetcher is only watching the context responses in which it is interested, so there is no particular need to verify URIs or otherwise demultiplex the responses unless the client has specifically multiplexed requests.

## EXAMPLE

There is an example of the multi-use case in TestScene.xml/TestScene.brs in this test channel.

The IP address and file name used should be edited in TestScene.brs, getUri(). The tester will need to set up an http server and put the files in place to run the test.

When running the test channel, pressing up and down adjusts an index number that is spliced into a URI that is fetched when OK/select is pressed. The results are dumped.
