dispd = {}
dispd.scl = 5
dispd.sda = 6
dispd.disp = nil
dispd.temperature = ""
dispd.humidity = ""
dispd.heat = true
dispd.cool = false
dispd.fan = true
dispd.humi = true
dispd.messages = { "initializing..." }
dispd.tmr = 1
dispd.interval = 1000
dispd.counter = 0

function dispd.start()
	dispd.setTemperature(0)
	dispd.setHumidity(0)
	
	i2c.setup(0, 5, 6, i2c.SLOW)
	dispd.disp = u8g.ssd1306_128x64_i2c(0x3c)
	dispd.disp:begin()
	dispd.render()
	
	tmr.alarm(dispd.tmr, dispd.interval, 1, dispd.render)
end

function dispd.render()
	local big
	
	if (math.floor(dispd.counter / 5) % 2 == 0) then
		big = dispd.temperature
	else
		big = dispd.humidity
	end
	
	local msg = (dispd.messages[dispd.counter % #dispd.messages + 1])

	dispd.disp:firstPage()
	repeat
		-- temp or humi
		dispd.disp:setFont(u8g.font_fub30)
		dispd.disp:drawStr(0, 32, big)
		dispd.disp:setFont(u8g.font_6x10)
		if (msg ~= nil) then
			dispd.disp:drawStr(0, 62, msg)
		end
		dispd.disp:setFont(u8g.font_unifont_78_79)
		if (dispd.cool) then
			dispd.disp:drawStr(112, 16, "D")
		end
		if (dispd.heat) then
			dispd.disp:drawStr(112, 16, "Á")
		end
		if (dispd.fan) then
			dispd.disp:drawStr(112, 38, "C")
		end
		if (dispd.humi) then
			dispd.disp:drawStr(112, 60, "(")
		end
	until dispd.disp:nextPage() == false
	
	dispd.counter = dispd.counter + 1
end

function dispd.setTemperature(temp)
	dispd.temperature = string.format("%.1f°", temp)
end

function dispd.setHumidity(humi)
	dispd.humidity = string.format("%d%%", humi)
end