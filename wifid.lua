wifid = {}
wifid.SSID = ""
wifid.password = ""
wifid.ip = "192.168.0.81"
wifid.netmask = "255.255.255.0"
wifid.gateway = "192.168.0.1"
wifid.server = "192.168.0.2"
wifid.gpio = 3
wifid.interval = 100
wifid.counter = 0

function wifid.connect()

	gpio.mode(wifid.gpio, gpio.OUTPUT)
	gpio.write(wifid.gpio, gpio.LOW)

	wifi.setmode(wifi.STATION)
	wifi.sta.config(wifid.SSID,wifid.password)	
	wifi.sta.connect()

	wifi.sta.setip(wifid)
	
	print("IP:", wifi.sta.getip())
		
	tmr.alarm(wifid.gpio, wifid.interval, 1, wifid.check)
end

function wifid.check()
	local led = 0
	local sta = wifi.sta.status()
	
	if (sta == 0) then
		led = 0
	elseif (sta == 1) then
		led = (wifid.counter / 5) % 2
	elseif (sta == 2 or
	        sta == 3 or
			sta == 4) then
		led = wifid.counter % 2
	elseif (sta == 5) then
		led = 1
	end
	
	gpio.write(wifid.gpio, led)
	
	wifid.counter = wifid.counter + 1
end