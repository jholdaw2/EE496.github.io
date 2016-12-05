wifi.sta.config("UHM", "")
print(wifi.sta.setip({
  ip = "168.105.10.212",
  netmask = "255.255.224.0",
  gateway = "168.105.0.1"
}))

if srv~=nil then
  srv:close()
end

led1 = 3
led2 = 4
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW);

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,payload)          --On receiving any http request, store in tgtfile
		   tgtfile = string.sub(payload,string.find(payload,"GET /")
           +5,string.find(payload,"HTTP/")-2)
		if tgtfile == "" then tgtfile = "index.htm" end  

        function mysplit(inputstr, sep)
          if sep == nil then
            sep = "%s"
          end
          local t={} ; i=1
         for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
           end
         return t
        end
        
        local para = mysplit(tgtfile, '?')[1]
		local f = file.open(para,"r")    
       
        local _, _, method, path, vars = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(payload, "([A-Z]+) (.+) HTTP");
        end
        
        local _GET = {}
        
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        if(_GET.pin ~= nil)then
               local para = mysplit(_GET.pin, 'x')
               print(para[1]);
 
        if(para[1] == "45098")then
                  if(para[2] == 'vert')then
                     pwm.setup(6,30,100); --
                     pwm.start(6);
                     pwm.setduty(6,para[3]);
                 elseif(para[2] == 'hori')then
                    pwm.setup(1,27,124)
                    pwm.start(1)
                    pwm.setduty(1,para[3])
                 elseif(para[2] == 'ON1')then
                    gpio.write(led1, gpio.HIGH);
                 elseif(para[2] == 'OFF1')then
                    gpio.write(led1, gpio.LOW);
                 elseif(para[2] == 'OFF2')then
                    gpio.write(led2, gpio.LOW);
                    tmr.delay(3000000);
                    gpio.write(led2, gpio.HIGH);
                 end
                 else
                    client:send('error');
              end
        end

        if f ~= nil then
            client:send(file.read())
            file.close()
        else
            client:send("<html>"..tgtfile.." not found - 404 error.<BR><a href='index.htm'>Home</a><BR>")
        end

		client:close();
		collectgarbage();
		f = nil
		tgtfile = nil
    end)
end)
