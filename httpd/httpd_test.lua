require "httpd"

h = httpd.create()

h:addhandler("GET", "/", function(params, headers)
	--return 200, "text/html", httpd.loadfile("hello.html")
	return 200, "text/html", "hello"
end)

method = "GET"
path = "/"
params = {}
headers = {}

buf = h:buildresponse("GET", "/", params, headers)

print(buf)

h:open()