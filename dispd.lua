dispd = {}
dispd.scl = 5
dispd.sda = 6
dispd.disp = nil
dispd.temperature = "00.0°"
dispd.humidity = "00.0%"
dispd.heat = true
dispd.cool = false
dispd.fan = true
dispd.humi = true
dispd.message = "initializing..."
dispd.tmr = 1
dispd.interval = 1000

function dispd.start()
	i2c.setup(0, 5, 6, i2c.SLOW)
	dispd.disp = u8g.ssd1306_128x64_i2c(0x3c)
	dispd.disp:begin()
	dispd.render()
	
	tmr.alarm(dispd.tmr, dispd.interval, 1, dispd.render)
end

function dispd.render()
	dispd.disp:firstPage()
	repeat
		dispd.disp:setFont(u8g.font_helvB24)
		dispd.disp:drawStr(0, 26, dispd.temperature)
		dispd.disp:setFont(u8g.font_6x10)
		dispd.disp:drawStr(0, 38, dispd.humidity)
		dispd.disp:drawStr(0, 62, dispd.message)
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
end