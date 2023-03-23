'********** Copyright 2019-2020 Roku Corp.  All Rights Reserved. **********

' Initializes the retriever task. In order to use the Roku Pay API
' endpoints, we need to set the partner and user IDs.
sub init()
	print "task INIT"

	m.port=createobject("roMessagePort")
	m.canUseUpdate = m.global.canUseUpdate
	initUriRequester(5)

	m.top.observefield("request", m.port)
	m.top.functionname="getdata"
end sub

' initUriRequester '
' Input: numObjects - number of roUrlTransfer objects used to init urlFreePool'
' Description: initializes queues used in the uri requester'
'			urlFreePool - an array with N pre-allocated roUrlTransfer objects'
'			urlInUsePool - an AA that holds the url objects that were requested, waiting for response'
'			reqPendingQueue - a queue holding requests that can't be satisfied momentarily'
'												because the free pool is empty'
function initUriRequester(numObjects as Integer) as Void
	m.urlInusePool = {}
	m.urlFreePool = []
	m.reqPendingQueue = []

	for i=1 to numObjects
		obj = createObject("roUrlTransfer")
		obj.SetCertificatesFile("common:/certs/ca-bundle.crt")
		m.urlFreePool.push(obj)
	end for
end function

' getData
' Input: none
' Description: Loops infinitely (until task is stopped), listening for requests made by
'			   setting the "request" field of this task. When receiving the request, it will
'			   call the appropriate function based on what command was specified in the request's
'			   "parameter" field.
'
function getdata()
	while true
		msg=wait(0,m.port)

		if type(msg) = "roSGNodeEvent"
			if msg.getField() = "request"
				' Call data source request function '
				request = msg.getData()
				context = request.context
				parameters = context.parameters
				command = lcase(parameters.command)

				if command = "getcatalog"
				    if lcase(parameters.type) = "get-products"
				        ? "Getting products..."
				        getProducts(context)
				    else if lcase(parameters.type) = "get-plans"
				        ? "Getting plans..."
				        getPlans(context)
				    else
				        ? "Invalid getCatalog type: " + parameters.type
				    end if
				else if command = "getpurchases"
				    ? "Getting purchases..."
				    getPurchases(context)
				else if command = "makepurchase"
				    ? "Making purchase..."
					makePurchase(context)
				else if command = "changepurchase"
				    ? "Changing purchase..."
					changePurchase(context)
				else if command = "cancelpurchase"
				    ? "Cancelling purchase..."
					cancelPurchase(context)
				else
				    ? "Invalid command..."
				end if
			else
				' what other fields?
				print "Field: ", msg.getField(), ", not handling..."
			end if
		else if type(msg) = "roUrlEvent"
			processUrlResponse(msg)
		else
			print "Unrecognized event type: '"; type(msg); "'"
		end if
	end while
end function

' makeUriRequest '
' Input: url -  url of the API request '
'        source - name of the data source, e.g. wiki '
'		 type - type of request, e.g. get-words-array, get-http-page'
'        op - one of "GET", "POST", "PUT", "DELETE" '
'        args - optional caller provided args '
' Description: make a web api request if an roUrlTransfer object is available in the free pool
'              or place the request in the pending queue if the free pool is empty; if the async request'
'			   can go thru, put the request in the in use pool (an AA) using the obj identity as key '
'			   The roUrlEvent async response is handled in function processUrlResponse'
'
function makeUriRequest(url as String, reqCtx as Object, headers as Object, op as String, args = invalid as Object) as Boolean
	ok = false
	if m.urlFreePool.Count() > 0
		' Get an object from the free pool
		obj = m.urlFreePool.Pop()
		obj.setUrl(url)
		obj.setHeaders(headers)
		obj.setPort(m.port)
		obj.enableEncodings(true)
		idKey = obj.getIdentity().toStr()


		print "send req: " + url

		if op = "GET"
		  obj.setRequest("GET")
			ok = obj.AsyncGetToString()
		else if op = "POST" or op = "PUT" or op = "DELETE"
		  dataStr = ""
		  if args <> invalid
			    dataStr = args["data"]
			end if
			obj.setRequest(op)
			obj.RetainBodyOnError(true)
			ok = obj.AsyncPostFromString(dataStr)
		else
			print "makeUriRequest() - invalid request op: "; op
		end if

		if not ok
			print "Failed due to: " + obj.GetFailureReason()
			' then what, try again? or return an error?
		else
			' put it in the in use pool
			m.urlInusePool.addReplace(idKey, {obj: obj, ctx: reqCtx})
		end if
	else
		' add to pending queue
		' (pending queue contains all data needed to make request, including op and args) '
		m.reqPendingQueue.push({url: url, reqCtx: reqCtx, headers: headers, op: op, args: args})
		ok = true
	end if
	return ok
end function

' processUrlResponse '
' Input: msg - the roUrlEvent'
' Description: processes the roUrlEvent, gets the object from the in use pool,
'			   and sends it to the data source for processing of the response
'			   when data source is done, returns the url object to the free pool
'			   and check if there are pending requests that need to be processed
'			   See initUriRequester comment for info on urlFreePool, urlInUsePool, and reqPendingQueue
'
function processUrlResponse(msg as object)
	idKey = msg.GetSourceIdentity().toStr()
	doneObj = m.urlInusePool[idKey]
	reqCtx = doneObj.ctx
	obj = doneObj.obj  ' the roUrlRequester object'

	response = {}
	response.addReplace("type", reqCtx.parameters.type)
	response.addReplace("id", reqCtx.parameters.id)
	response.addReplace("responsecode", msg.getResponseCode())
	responseData = msg.getString()
	if msg.getResponseCode() = 200
			response.addReplace("data", parseJson(responseData))
			' print "Success (200) response data= "; msg.getString()
			print "Success (200)"
	else
			print "Response data="; msg.getString()
			print "length of data="; len(msg.getString())
			response.addReplace("data", msg.getFailureReason())
	end if
	reqCtx.response = response


	m.urlInusePool.delete(idKey)
	m.urlFreePool.push(obj)

	count = m.urlFreePool.Count()
	print "There are " + stri(count) + " objects in free pool"
	'if there are jobs in the pending queue, dispatch first
	count = m.reqPendingQueue.Count()
	print "There are " + stri(count) + " entries in pending queue"
	if count > 0
		' Get item from pending, make request
		pendingObj = m.reqPendingQueue.shift()
		url = pendingObj.url
		reqCtx = pendingObj.reqCtx
		headers = pendingObj.headers
		op = pendingObj.op
		args = pendingObj.args

		'TODO: need to store data source in pending queue'
		makeUriRequest(url, reqCtx, headers, op, args)
	end if

end function
