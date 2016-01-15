function getdhtresponse(filename, params, headers)
	local _, temp, humi = dht.read(tonumber(params.gpio))
	local buf = h:loadfile(filename)
	buf = string.gsub(buf, "__t__", temp)
	buf = string.gsub(buf, "__h__", humi)
	return buf
end

h:addhandler("GET", "/dht", "text/html", function(params, headers)
	return getdhtresponse("dht.html", params, headers)
end)

h:addhandler("GET", "/dht", "text/json", function(params, headers)
	return getdhtresponse("dht.json", params, headers)
end)

h:addhandler("GET", "/dht", "text/plain", function(params, headers)
	return getdhtresponse("dht.txt", params, headers)
end)