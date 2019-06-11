--主机发送数据到播放器的方法处理

ProxyHelper = {}
ProxyHelper.TCPReceiveBuf = ""
ProxyHelper.CommandList = {}

DriverHelper = {}
gCurrentScan = 0

function ProxyHelper.Scan()
	ProxyHelper.GetNextMediaLib(1)
	--gScan = true
	-- body
	g_SCAN = true
	DriverHelper.CheckScan = DriverHelper.AddTimer(DriverHelper.CheckScan, 10, "MINUTES", true);
	--gCurrentScan = gCurrentScan + 1
	C4:UpdateProperty("Scan Progress"," Starting Scan !!! ")
end

function ProxyHelper.BuildCommand(data)
	return data .."\n\v\f\r"
end

function ProxyHelper.SendCommand(cmd)
     --print(cmd)
	C4:SendToNetwork(6001,60001,ProxyHelper.BuildCommand(cmd))
end

function ProxyHelper.AddCommandList(cmd, pos)
	--if (inSonaLicHelper.HasActivedLicense() ~= true) then return; end
	if (pos ~= nil and #ProxyHelper.CommandList > 0 ) then
		table.insert(ProxyHelper.CommandList, pos, cmd);
	else
		table.insert(ProxyHelper.CommandList, cmd);
	end
end

function ProxyHelper.SendCommandList()
	if (#ProxyHelper.CommandList > 0) then
		local cmd = ProxyHelper.BuildCommand(ProxyHelper.CommandList[1])
		ProxyHelper.SendCommand(cmd)
		print("Send cmd to player "..cmd)
		table.remove(ProxyHelper.CommandList, 1);	
     else
	   if(gScan) then
		  print("Scan is compeleted !!!")
		  gScan = false
		  --BuildListIteams()
	   end
	end
end


function ProxyHelper.SaveInfo(musictype,musicdata)
	-- 保存媒体数据
	local musicname = musictype .. ".txt"
	C4:FileDelete(musicname);
	local fh = C4:FileOpen(musicname)
	local info = {}
	if (fh ~= -1) then	
		C4:FileWriteString(fh,musicdata)
		C4:FileClose(fh)
	end
end


function ProxyHelper.ReadInfo( musictype )
	local musicname = musictype ..".txt"
	local fh = C4:FileOpen(musicname)
	local inf = {}
	if(fh ~= -1) then
		local fileSize = C4:FileGetSize(fh)
		C4:FileSetPos(fh,0)
		local rawdata = C4:FileRead(fh,fileSize)
		info = json:decode(rawdata)
	end
	return info
end

--[[
function ProxyHelper.ConnectServer()		
	-- body
	C4:CreateNetworkConnection (6001, g_ServerIPAddress, "TCP")
	
	C4:NetConnect(6001, 60001)
end
]]-- 
function GetNowplayList() 	-- 获取当前播放列表
	local cmd = '{"action":"action.request.musiclist"}'
	ProxyHelper.SendCommand(cmd)
end

function OnConnectionStatusChanged(idBinding, nPort, strStatus)
    C4:UpdateProperty("Connection Status", strStatus)
      if (idBinding == 6001) then
		--  gConnectStatus = strStatus
        if (strStatus == "ONLINE") then
          	print("Connect was successful.  Send URL packet.")
			GetCurrentVolume()
			--DriverHelper.KillTimer(DriverHelper.Reconnect)
        else
        	print("send connect to moudel")
        	--ProxyHelper.ConnectServer()
        	--DriverHelper.Reconnect = DriverHelper.AddTimer(DriverHelper.Reconnect, 10, "MINUTES", true);
	   end 
      end
end



function GetCurrentVolume()
    local cmd = '{"action":"action.request.getVolume"}'
    ProxyHelper.SendCommand(cmd)
end


--进度条

function ConvertTime (data, incHours)
	-- Converts a string of [HH:]MM:SS to an integer representing the number of seconds
	-- Converts an integer number of seconds to a string of [HH:]MM:SS. If HH is zero, it is omitted unless incHours is true

	if (data == nil) then
		return (0)
	elseif (type (data) == 'number') then
		local strTime = ''
		local minutes = ''
		local seconds = ''
		local hours = string.format('%d', data / 3600000)
		data = data - (hours * 3600000)

		if (hours ~= '0' or incHours) then
			strTime = hours .. ':'
			minutes = string.format('%02d', data / 60000)
		else
			minutes = string.format('%d', data / 60000)
		end

		data = data - (minutes * 60000)
		seconds = string.format('%02d', data/1000)
		strTime = strTime .. minutes .. ':' .. seconds
		return strTime

	elseif (type (data) == 'string') then
		local hours, minutes, seconds = string.match (data, '^(%d-):(%d-):?(%d-)$')

		if (hours == '') then hours = nil end
		if (minutes == '') then minutes = nil end
		if (seconds == '') then seconds = nil end

		if (hours and not minutes) then minutes = hours hours = 0
		elseif (minutes and not hours ) then hours = 0
		elseif (not minutes and not hours) then minutes = 0 hours = 0 seconds = seconds or 0
		end

		hours, minutes, seconds = tonumber (hours), tonumber (minutes), tonumber (seconds)
		return ((hours * 3600) + (minutes * 60) + seconds)
	end
end
function UpdateProgress (duration,elapsed)
	

	local label = ConvertTime (elapsed) .. ' / -' .. ConvertTime (duration)

	local progressInfo = {
							length = duration,	-- integer for setting size of duration bar
							offset = elapsed,	-- integer for setting size of elapsed indicator inside duration bar
							label = label,		-- text string to be displayed next to duration bar
						}
       local data = XMLTag(nil,progressInfo,false,false)
      -- print(data)
       local tResponse = {}
       tResponse["NAME"] = "ProgressChanged"
       tResponse["EVTARGS"] = data
	SendToProxy(5001, "SEND_EVENT", tResponse,"COMMAND")
end


