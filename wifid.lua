wifid = {}
wifid.SSID = nil
wifid.password = nil
wifid.apcounter = 0
wifid.hostname = "nodeMCU"
wifid.ip = "192.168.0.81"
wifid.netmask = "255.255.255.0"
wifid.gateway = "192.168.0.1"
wifid.server = "192.168.0.2"
wifid.gpio = 8
wifid.tmr = 0
wifid.interval = 200
wifid.counter = 0
wifid.gotip = false

function wifid.start()
	gpio.mode(wifid.gpio, gpio.OUTPUT)
	gpio.write(wifid.gpio, gpio.LOW)
	
	tmr.alarm(wifid.tmr, wifid.interval, 1, wifid.event)
	
	wifid.connect()
end

function wifid.connect()
	if pcall(wifid.init) then
		wifi.sta.connect()
	end
	
	wifid.apcounter = wifid.apcounter + 1
end

function wifid.init()
	local i = wifid.apcounter % #wifid.SSID + 1
	wifi.setmode(wifi.STATION)
	wifi.sta.sethostname(wifid.hostname)
	wifi.sta.config(wifid.SSID[i], wifid.password[i])
	wifi.sta.setip(wifid)
end

function wifid.event()
	local i = wifid.apcounter % #wifid.SSID + 1
	local sta = wifi.sta.status()
	local ip = ""
	local ssid = ""
	local led = 0
	local msg = nil
		
	if (sta == wifi.STA_IDLE) then
		led = 0
		msg = nil
	elseif (sta == wifi.STA_CONNECTING) then
		led = (wifid.counter / 3) % 2
		if (led == 1) then
			msg = "wifi connecting..."
		else
			msg = wifid.SSID[i]
		end
		wifid.gotip = false
	elseif (sta == wifi.STA_WRONGPWD or sta == wifi.STA_APNOTFOUND or sta == wifi.STA_FAIL) then
		if (sta == wifi.STA_WRONGPWD) then
			msg = "wrong password"
		elseif (sta == wifi.STA_APNOTFOUND) then
			msg = "wifi AP not found"
		elseif (sta == wifi.STA_FAIL) then
			msg = "wifi failed"
		end
		wifid.gotip = false
		wifi.sta.disconnect()
		wifid.connect()
		led = wifid.counter % 2
	elseif (sta == wifi.STA_GOTIP) then
		ip = wifi.sta.getip()
		led = 1
		if (wifid.gotip == false) then
			print("Connected to: " .. ssid .. " IP: " .. ip)
			msg = "wifi connected"
			wifid.gotip = true
		end
	end
	
	wifid.flashled(led)
	
	if (dispd ~= nil and msg ~= nil) then
		dispd.message = msg
	end
	
	wifid.counter = wifid.counter + 1
end

function wifid.flashled(led)
	gpio.write(wifid.gpio, led)
end