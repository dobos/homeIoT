wifi.setmode(wifi.STATION)
wifi.sta.config("***","***")
wifi.sta.connect()

wifi.sta.setip({ip="192.168.0.81",netmask="255.255.255.0",gateway="192.168.0.1"})

require "httpd"
h = httpd.create()

dofile("dht.lua")

h:open()