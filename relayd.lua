relayd = {}
relayd.ports = { 5 }

function relayd.create(ports)
	relayd.ports = ports
	for i, p in ipairs(ports) do
		gpio.mode(p, gpio.OUTPUT)
		gpio.write(p, 1)
	end
	
	httpd.addhandler("GET", "/relay", 1, "text/html", function(params, headers)	
		relayd.switch(params)
		
		local buf = "<html><body>"
		for i, p in ipairs(ports) do
			buf = buf .. '<form action="/relay" method="get">'
			buf = buf .. '<input type="hidden" name="port" value="' .. i .. '" />'
			buf = buf .. '<input type="submit" name="s" value="'
			if (gpio.read(p) == 0) then
				buf = buf .. 'off" text="OFF" />'
			else
				buf = buf .. 'on" text="ON" />'
			end
			buf = buf .. '</form>'
		end
		buf = buf .. "</body></html>"
		return buf
	end )
end

function relayd.switch(params)
	if (params.port ~= nil) then
		local p = tonumber(params.port)
		if (params.s == "on") then
			gpio.write(relayd.ports[p], 0)
		elseif (params.s == "off") then
			gpio.write(relayd.ports[p], 1)
		end
	end
end