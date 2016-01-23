wifid = {}
wifid.SSID = ""
wifid.password = ""
wifid.ip = "192.168.0.81"
wifid.netmask = "255.255.255.0"
wifid.gateway = "192.168.0.1"
wifid.server = "192.168.0.2"
wifid.gpio = 8
wifid.tmr = 3
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
		
	tmr.alarm(wifid.tmr, wifid.interval, 1, wifid.check)
end

function wifid.check()
	local led = 0
	local sta = wifi.sta.status()
	
	if (sta == wifi.STA_IDLE) then
		led = 0
	elseif (sta == wifi.STA_CONNECTING) then
		led = (wifid.counter / 5) % 2
	elseif (sta == wifi.STA_WRONGPWD or
	        sta == wifi.STA_APNOTFOUND or
			sta == wifi.STA_FAIL) then
		led = wifid.counter % 2
	elseif (sta == wifi.STA_GOTIP) then
		led = 1
	end
	
	gpio.write(wifid.gpio, led)
	
	wifid.counter = wifid.counter + 1
end

function wifid.flashled(led)
	gpio.write(wifid.gpio, led)
end