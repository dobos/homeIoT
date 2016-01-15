srv = {}
srv.listen = function(a, b) end
net = {}
net.createServer = function(x) return srv end


require "httpd"

h = httpd.create()

h:addhandler("GET", "/", "text/plain", function(params, headers)
	return 200, "text/html", "hello"
end)

h:addhandler("GET", "/", "text/json", function(params, headers)
	return 200, "text/json", "{ \"hello\":\"world\" }"
end)

method = "GET"
path = "/"
params = {}
headers = {}

headers.Accept = "text/plain"
buf = h:buildresponse("GET", "/", params, headers)
print(buf)

headers.Accept = "text/json"
buf = h:buildresponse("GET", "/", params, headers)
print(buf)

headers.Accept = "text/*"
buf = h:buildresponse("GET", "/", params, headers)
print(buf)

headers.Accept = "*/*"
buf = h:buildresponse("GET", "/", params, headers)
print(buf)

headers.Accept = "text/xml"
buf = h:buildresponse("GET", "/", params, headers)
print(buf)

h:open()