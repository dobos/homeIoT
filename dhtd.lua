dhtd = {}
dhtd.tmr = 2
dhtd.gpio = 2
dhtd.interval = 5000
dhtd.counter = 0
dhtd.temperature = 0.0
dhtd.humidity = 0.0

function dhtd.start()
	tmr.alarm(dhtd.tmr, dhtd.interval, 1, dhtd.on_event)
end

function dhtd.on_event()
	_, dhtd.temperature, dhtd.humidity = dht.read(dhtd.gpio)
	
	if (dispd ~= nil) then
		dispd.temperature = string.format("%.1f°", dhtd.temperature)
		dispd.humidity = string.format("%d%%", dhtd.humidity)
	end
end