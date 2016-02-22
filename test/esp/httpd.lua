-- mock nodeMCU classes

srv = {}
srv.listen = function(a, b) end
net = {}
net.createServer = function(x) return srv end
file = {}
file.open = function(a, b) return true end
file.seek = function(a, b) end
file.read = function(n) return "aaa" end
file.close = function() end
trace = function(msg) print(msg) end

function createHttpd()
	local httpd = require("httpd")
	local h = httpd.new()
	return h
end

local getreq = 
[[GET /test HTTP/1.1
User-Agent: curl/7.40.0
Host: 192.168.0.81
Accept: text/plain
]]

local postreq = 
[[POST /srv2.lua?edit&test=yes HTTP/1.1
User-Agent: curl/7.40.0
Host: 192.168.0.81
Accept: */*
Content-Length: -1

This is a test
]]

print()
print()
print("+++ Testing parseMethod")
print()

do
	local h = createHttpd()
	local method, url, params = h.parseMethod(postreq)

	assert(method == "POST")
	assert(url == "srv2.lua")
	assert(params["edit"] ~= nil)
	assert(params["test"] == "yes")
	--for k,v in pairs(params) do
	--	print ("        " .. k .. ": " .. v)
	--end
end

print()
print()
print("+++ Testing parseRequest")
print()

do
	local h = createHttpd()
	h:parseRequest(postreq)
	
	assert(h.method == "POST")
	assert(h.url == "srv2.lua")
	assert(h.params["edit"] ~= nil)
	assert(h.params["test"] == "yes")
	assert(h.headers["User-Agent"] == "curl/7.40.0")
	assert(h.headers["Host"] == "192.168.0.81")
	assert(h.headers["Accept"] == "*/*")
	assert(h.headers["Content-Length"] == "-1")
end

print()
print()
print("+++ Testing addHandler and getHandler")
print()

do
	local h = createHttpd()

	local handler =
	{
		url = "test",
		mime = "text/plain",
		idx = 0,
		http_req_GET = function(self, httpd, payload, continue)
			return false
		end,
		http_res_GET = function(self, httpd, continue)
			return httpd:respond200(self.mime, 10, false)
		end
	}

	h:addHandler(handler)

	h:parseRequest(getreq)
	local res, v = h:getHandler(h.url)
	assert(v.mime == "text/plain")
end

print()
print()
print("+++ Testing missing handler")
print()

do
	local h = createHttpd()

	local req = [[GET /test HTTP/1.1
User-Agent: curl/7.40.0
Host: 192.168.0.81
Accept: text/plain
]]

	local handler =
	{
		url = "alma",
		method = "GET",
		mime = "text/plain",
		idx = 0,
		respond = function(self, httpd)
			return httpd:respond200(self.mime, 10, false)
		end
	}

	h:addHandler(handler)

	h:parseRequest(getreq)
	local res, v = h:getHandler(h.url)
	assert(v == nil)
end


print()
print()
print("+++ Testing Httpd_file")
print()

do
	local h = createHttpd()

	local getfilereq = 
[[GET /file/test.lua HTTP/1.1
User-Agent: curl/7.40.0
Accept: */*
]]

	local http_file = require("httpd_file")
	local gf = http_file.new()
	
	h:addHandler(gf)
	
	h:parseRequest(getfilereq)

end
