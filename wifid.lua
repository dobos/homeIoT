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
	for i = 0, #wifid.SSID do
		if pcall(wifid.init) then
			wifi.sta.connect()
		else
			wifid.apcounter = wifid.apcounter + 1
		end
	end
end

function wifid.init()
	local i = (wifid.apcounter % #wifid.SSID) + 1
	wifi.setmode(wifi.STATION)
	wifi.sta.sethostname(wifid.hostname)
	wifi.sta.setip(wifid)
	wifi.sta.config(wifid.SSID[i], wifid.password[i], 0)
end

function wifid.event()
	local i = (wifid.apcounter % #wifid.SSID) + 1
	local sta = wifi.sta.status()
	local ssid = (wifid.SSID[i])
	local ip = ""
	local led = 0
	local msg = nil
		
	if (sta == wifi.STA_IDLE) then
		led = 0
	elseif (sta == wifi.STA_CONNECTING) then
		led = math.floor(wifid.counter / 3) % 2
		wifid.gotip = false
		msg = { "wifi connecting to", ssid }
	elseif (sta == wifi.STA_WRONGPWD or sta == wifi.STA_APNOTFOUND or sta == wifi.STA_FAIL) then
		led = wifid.counter % 2
		wifid.gotip = false
		
		if (sta == wifi.STA_WRONGPWD) then
			msg = { "wrong password" }
		elseif (sta == wifi.STA_APNOTFOUND) then
			msg = { "wifi AP not found" }
		elseif (sta == wifi.STA_FAIL) then
			msg = { "wifi failed" }
		end
		
		wifi.sta.disconnect()
	elseif (sta == wifi.STA_GOTIP) then
		ip, _, _ = wifi.sta.getip()
		led = 1
		if (wifid.gotip == false) then
			msg = { "wifi connected" , ssid }
			wifid.gotip = true
		end
	end
	
	wifid.flashLed(led)
	wifid.printMessage(msg)
	
	wifid.counter = wifid.counter + 1

	if (sta == wifi.STA_WRONGPWD or sta == wifi.STA_APNOTFOUND or sta == wifi.STA_FAIL) then
		wifid.apcounter = wifid.apcounter + 1
		wifid.connect()
	end
end

function wifid.flashLed(led)
	gpio.write(wifid.gpio, led)
end

function wifid.printMessage(msg)
	--if (msg ~= nil) then
	--	for i,v in ipairs(msg) do print(v) end
	--end
	
	if (dispd ~= nil and msg ~= nil) then
		dispd.messages = msg
	end
end