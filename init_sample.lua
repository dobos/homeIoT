dofile("wifid.lua")
wifid.SSID = "***"
wifid.password = "***"
wifid.connect()


dofile("httpd.lua")
httpd.create()

dofile("dhtd.lua")
dhtd.create(2, 5000)

dofile("relayd.lua")
relayd.create({ 5 })

httpd.open()