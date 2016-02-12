dhtd = {}
dhtd.temperature = 0.0
dhtd.humidity = 0.0

function dhtd.getresponse(filename, params, headers)
	local buf = httpd.loadfile(filename)
	buf = string.gsub(buf, "__t__", dhtd.temperature)
	buf = string.gsub(buf, "__h__", dhtd.humidity)
	return buf
end

function dhtd.create(gpio, interval)
	dhtd.gpio = gpio
	dhtd.interval = interval

	httpd.addhandler("GET", "/dht", 1, "text/html", function(params, headers)
		return dhtd.getresponse("dht.html", params, headers)
	end)

	httpd.addhandler("GET", "/dht", 2, "text/json", function(params, headers)
		return dhtd.getresponse("dht.json", params, headers)
	end)

	httpd.addhandler("GET", "/dht", 3, "text/plain", function(params, headers)
		return dhtd.getresponse("dht.txt", params, headers)
	end)

	-- init timer, use same id as gpio port
	tmr.alarm(dhtd.gpio, dhtd.interval, 1, function()
		_, dhtd.temperature, dhtd.humidity = dht.read(dhtd.gpio)
	end)
end