--程序入口

require "cmd"    --对外和协议内命令实现
require "feedback"   --数据反馈处理
require "parsemessage"   --对数据解析
require "action"    --方法实现
require "commands"  --编程调用
--------------------data process-------------------------
----------------------------------------------------------
json = require("json")
-- Constants
DEFAULT_PROXY_BINDINGID = 5001     
GENERIC_MEDIA_PROXY_BINDING_ID = 5001

--image path
gControllerIPAddress = C4:GetControllerNetworkAddress()
gMediaPath = "http://" .. gControllerIPAddress .. "/driver/MiYue/media/"


DriverHelper = {}

g_MediaByKey = {}
g_boardMusicInfo = {}

gQueues = {}          	-- Audio queue information of any queues that this driver created or plays audio in
gNowPlaying = {}		-- Now playing information for any queues that this driver created or plays audio in
gCurrentSongIndex = 1


g_LocalMusic = {}
g_CollectedBoards = {}
g_CollectedRadios = {}
g_songlist = {}

gScan = false
DEBUGMODE = false

gCurrentSongTitle = ""
gConnectStatus = "OFFLINE"

--g_ServerIPAddress = Properties["IP Address"]
	   
g_DriverVersion = "V1.02"
--数据解析


function ProxyHelper.GetNextMediaLib(seq)	
	-- body
	local lib = {"localmusic","raido","wangyiyun","douban","collectedMusic","collectedBoards","collectedRadios","collectedSonglist"}

	local msg_id = {'{"action":"action.request.getlocalMusic"}','{"action":"action.request.getradioInfo"}',
	                '{"action":"action.request.getwangyiboards"}','{"action":"action.douban.getdirinfos"}',
				 '{"action":"action.request.collectedMusic"}','{"action":"action.request.collectedBoards"}',
				 '{"action":"action.request.collectedRadios"}',
	                '{"action":"action.request.collectedSonglist"}'}
	if (lib[seq]) then							--first, request media lib accordingly
		--print("Start to request " ..lib[seq])
		local cmd = msg_id[seq]
		ProxyHelper.AddCommandList(cmd)
	end
	
end


function ReceivedFromNetwork(idBinding, nPort, strData)
	if (strData == nil) then return end
	ProxyHelper.TCPReceiveBuf = ProxyHelper.TCPReceiveBuf .. strData
	if (string.sub(ProxyHelper.TCPReceiveBuf,-4) ~= "\n\v\f\r") then
		--print("Incomplete message received ...")
		return	  
	else
		--print("Begin to process message received...")
		--
		ProxyHelper.TCPReceiveBuf = string.gsub(ProxyHelper.TCPReceiveBuf,"\n\v\f\r","")
		local tmp = json:decode(ProxyHelper.TCPReceiveBuf)
		ParseFeedback(ProxyHelper.TCPReceiveBuf)
	end		
end

function dbg(str) 
    if(DEBUGMODE) then
       print(str)
    end
end



--------------------UI CONFIGURE----------------------------



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- Driver Declarations
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--[[
	Command Handler Tables
--]]

--require "driver"
--require "data"



g_browse_mainmenu = {
	{type = "local", folder = "true", text = "本机", URL = "", key = "local", ImageUrl = gMediaPath .. "ico_tunein_music.png"},
	{type = "link", folder = "true", text = "电台", URL = "", key = "radio", ImageUrl = gMediaPath .."ico_tunein_news.png"},
	{type = "link", folder = "true", text = "网易云", URL = "", key = "wangyi", ImageUrl = gMediaPath .."ico_tunein_trending.png"},
	{type = "link", folder = "true", text = "豆瓣FM", URL = "", key = "douban", ImageUrl = gMediaPath .."ico_tunein_trending.png"},
}

g_browse_music = {
	{text="收藏列表", is_header="true"},
	{type = "cmusic", folder = "true", text = "歌曲", subtext = "", URL = "", key = "local" ,ImageUrl = gMediaPath .. "ico_tunein_music.png"},
	{type = "link", folder = "true", text = "歌单", subtext = "", URL = "", key = "songlist",ImageUrl = gMediaPath .. "act_icotab_preset_dn.png"},
	{type = "link", folder = "true", text = "榜单", subtext = "", URL = "", key = "boards",ImageUrl = gMediaPath .. "ico_tunein_trending.png"},
	{type = "cradios", folder = "true", text = "电台", subtext = "", URL = "", key = "radios",ImageUrl = gMediaPath .. "ico_tunein_podcast.png"},	
}



-- http://lua-users.org/wiki/StringRecipes
function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "%%20")
  end
  return str	
end


---------------------------------------------------------------------
-- ReceivedFromProxy Code
---------------------------------------------------------------------
--[[
	ReceivedFromProxy(idBinding, sCommand, tParams)
		Function called by Director when a proxy bound to the specified binding sends a
		BindMessage to the DriverWorks driver.

	Parameters
		idBinding
			Binding ID of the proxy that sent a BindMessage to the DriverWorks driver.
		sCommand
			Command that was sent
		tParams
			Lua table of received command parameters
--]]
function ReceivedFromProxy(idBinding, sCommand, tParams)
	if (sCommand ~= nil) then
		if(tParams == nil)		-- initial table variable if nil
			then tParams = {}
		end
		dbg("ReceivedFromProxy(): " .. sCommand .. " on binding " .. idBinding .. "; Call Function " .. sCommand .. "()")
		PrintTable(tParams, "     ")
		if (PRX_CMD[sCommand]) ~= nil then
			PRX_CMD[sCommand](idBinding, tParams)
		else
			print("ReceivedFromProxy: Unhandled command = " .. sCommand)
		end
	end
end

function ParseProxyCommandArgs(tParams)
	local args = {}
	local parsedArgs = C4:ParseXml(tParams["ARGS"])
	for i,v in pairs(parsedArgs.ChildNodes) do
		args[v.Attributes["name"]] = v.Value
	end
	return args
	
end



---------------------------------------------------------------------
-- Proxy Functions
---------------------------------------------------------------------



function ClearNowPlayingQueue(queueId)
	print("ClearNowPlayingQueue .........")
	--gNowPlaying = {}	
	gCurrentSongTitle = ""
	-- Update all navigators that care
	--SendQueueChangedEvent(queueId, gNowPlaying)
end

function UpdateVolume(vol)
    local level = vol
    C4:SendToProxy(5002, "VOLUME_LEVEL_CHANGED", {LEVEL = level, OUTPUT = 4001})
   -- print("vol is " .. level)
    if(vol > 0) then
	   C4:SendToProxy (5002, "MUTE_CHANGED", {MUTE = false, OUTPUT = 4001})
    elseif(vol == 0) then
	   C4:SendToProxy (5002, "MUTE_CHANGED", {MUTE = true, OUTPUT = 4001})
    end
end

--BrowseMusicCollection Action Command


---------------------------------------------------------------------
-- Notification Functions
---------------------------------------------------------------------
function SendToProxy(idBinding, strCommand, tParams, strCallType, bAllowEmptyValues)
	dbg("SendToProxy (" .. idBinding .. ", " .. strCommand .. ")")
	--PrintTable(tParams, "     ")
	if (strCallType ~= nil) then
		if (bAllowEmptyValues ~= nil) then
			C4:SendToProxy(idBinding, strCommand, tParams, strCallType, bAllowEmptyValues)
		else
			C4:SendToProxy(idBinding, strCommand, tParams, strCallType)
		end
	else
		if (bAllowEmptyValues ~= nil) then
			C4:SendToProxy(idBinding, strCommand, tParams, bAllowEmptyValues)
		else
			C4:SendToProxy(idBinding, strCommand, tParams)
		end
	end
end

function SendEvent(idBinding, navId, tRooms, name, tArgs)
	-- This function must have a registered navigator event set up
	local tParams = {}
	if (navId ~= nil) then
		tParams["NAVID"] = navId
		--dbg("SendEvent " .. name .. " to navigator " .. navId)
	elseif (tRooms ~= nil) then
		local rooms = ""
		for i,v in pairs(tRooms) do
			if (string.len(rooms) > 0) then
				rooms = rooms .. ","
			end
			rooms = rooms .. tostring(v)
		end
		
		if (string.len(rooms) > 0) then
			tParams["ROOMS"] = rooms
		end
		--dbg("SendEvent " .. name .. " to navigators in rooms " .. rooms)
	else
		--dbg("SendEvent " .. name .. " to all navigators (broadcast)")
	end
	tParams["NAME"] = name
	tParams["EVTARGS"] = BuildListXml(tArgs, true)
	SendToProxy(idBinding, "SEND_EVENT", tParams, "COMMAND")
end

function BroadcastEvent(idBinding, name, tArgs)
	local tParams = {}
	tParams["NAME"] = name
	tParams["EVTARGS"] = BuildSimpleXml(nil, tArgs, true)
	SendToProxy(idBinding, "SEND_EVENT", tParams, "COMMAND")	
	
end

function SendQueueChangedEvent(queueId, tArgs)
	print("SendQueueChangedEvent(" .. queueId .. ")")
	local tRooms = GetRoomsByQueue(nil, queueId)
	if (tRooms ~= nil) then
		SendEvent(GENERIC_MEDIA_PROXY_BINDING_ID, nil, tRooms, "QueueChanged", tArgs)
	end
end
---------------------------------------------------------------------
-- Helper Functions
---------------------------------------------------------------------
function getFavorites()
	local t = {}
	for i,v in pairs(g_MediaByKey) do
		if (v.is_preset == "true")  then
			table.insert(t, v) 
		end
	end
	return t
end

function BuildSimpleXml(tag, tData, escapeValue)
	local xml = ""
	
	if (tag ~= nil) then
		xml = "<" .. tag .. ">"
	end
	
	if (escapeValue) then
		for i,v in pairs(tData) do
			xml = xml .. "<" .. i .. ">" .. C4:XmlEscapeString(v) .. "</" .. i .. ">"
		end
	else
		for i,v in pairs(tData) do
			xml = xml .. "<" .. i .. ">" .. v .. "</" .. i .. ">"
		end
	end
	
	if (tag ~= nil) then
		xml = xml .. "</" .. tag .. ">"
	end
	return xml
end


function XMLEncode (s)
	if (s == nil) then return end

	s = string.gsub (s, '&', '\&amp\;')
	s = string.gsub (s, '"', '\&quot\;')
	s = string.gsub (s, '<', '\&lt\;')
	s = string.gsub (s, '>', '\&gt\;')
	s = string.gsub (s, "'", '\&apos\;')

	return s
end

function XMLTag (strName, tParams, tagSubTables, xmlEncodeElements)
	local retXML = {}
	if (type (strName) == 'table' and tParams == nil) then
		tParams = strName
		strName = nil
	end
	if (strName) then
		table.insert (retXML, '<')
		table.insert (retXML, tostring (strName))
		table.insert (retXML, '>')
	end
	if (type (tParams) == 'table') then
		for k, v in pairs (tParams) do
			if (v == nil) then v = '' end
			if (type (v) == 'table') then
				if (k == 'image_list') then
					for _, image_list in pairs (v) do
						table.insert (retXML, image_list)
					end
				elseif (tagSubTables == true) then
					table.insert (retXML, XMLTag (k, v))
				end
			else
				if (v == nil) then v = '' end
				table.insert (retXML, '<')
				table.insert (retXML, tostring (k))
				table.insert (retXML, '>')
				if (xmlEncodeElements ~= false) then
					table.insert (retXML, XMLEncode (tostring (v)))
				else
					table.insert (retXML, tostring (v))
				end
				table.insert (retXML, '</')
				table.insert (retXML, string.match (tostring (k), '^(%S+)'))
				table.insert (retXML, '>')
			end
		end
	elseif (tParams) then
		if (xmlEncodeElements ~= false) then
			table.insert (retXML, XMLEncode (tostring (tParams)))
		else
			table.insert (retXML, tostring (tParams))
		end

	end
	if (strName) then
		table.insert (retXML, '</')
		table.insert (retXML, string.match (tostring (strName), '^(%S+)'))
		table.insert (retXML, '>')
	end
	return (table.concat (retXML))
end

function BuildListXml(tData, escapeValue)
--print("BuildListXml, tData:")
--PrintTable(tData, "     ")
	local xml = ""

	xml = "<List>"

	if (escapeValue) then
		for j,k in pairs(tData) do
			xml = xml .. "<item>"
			for i,v in pairs(k) do
				xml = xml .. "<" .. i .. ">" .. C4:XmlEscapeString(v) .. "</" .. i .. ">"
			end	
			xml = xml .. "</item>"
		end	
	else
		for j,k in pairs(tData) do
			xml = xml .. "<item>"
			for i,v in pairs(k) do
				xml = xml .. "<" .. i .. ">" .. v .. "</" .. i .. ">"
			end	
			xml = xml .. "</item>"
		end
	end
	
	xml = xml .. "</List>"
	
	return xml
end

function DataReceivedError(idBinding, navId, seq, msg)
	local tResponse = {}
	tResponse["NAVID"] = navId
	tResponse["SEQ"] = seq
	tResponse["DATA"] = ""
	tResponse["ERROR"] = msg
	SendToProxy(idBinding, "DATA_RECEIVED", tResponse)
end

function DataReceived(idBinding, navId, seq, response)
	local data 
	if (type(response) == "table") then
		data = BuildListXml(response, true)
	else	
		data = response
	end
	
	local tResponse = {
		["NAVID"] = navId,
		["SEQ"] = seq,
		["DATA"] = data,
	}
	SendToProxy(idBinding, "DATA_RECEIVED", tResponse)	
end

function UpdateMediaInfo(idBinding, line1, line2, line3, line4, url, roomId, mediatype, merge)
	   if(url ~= nil) then
		tResponse = {
			["LINE1"] =  line1,
			["LINE2"] =  line2,
			["LINE3"] =  line3,
			["LINE4"] =  line4, 
			["IMAGEURL"] = C4:Base64Encode(url),
			["ROOMID"] = roomId,
			["MEDIATYPE"] = mediatype,
			["MERGE"] = merge,
		}	
		
	   else
		  tResponse = {
			["LINE1"] =  line1,
			["LINE2"] =  line2,
			["LINE3"] =  line3,
			["LINE4"] =  line4, 
			["IMAGEURL"] = C4:Base64Encode(gMediaPath .. "ico_tunein_music.png"),
			["ROOMID"] = roomId,
			["MEDIATYPE"] = mediatype,
			["MERGE"] = merge,
		}	
	   end
		
		SendToProxy(idBinding, "UPDATE_MEDIA_INFO", tResponse, "COMMAND", true)
		C4:SendToDevice(roomId, "SELECT_AUDIO_DEVICE", {deviceid = 1+C4:GetDeviceID()});   --发送刷新导航左下方的当前播放信息
			
end


function QueueChanged(idBinding, navId, roomId, args)
     
	local tResponse = {}
	
	tResponse["NAME"] = "QueueChanged"
	tResponse["EVTARGS"] = args

	SendToProxy(idBinding, "SEND_EVENT", tResponse, "COMMAND")	
end
	  
function PrintTable(tValue, sIndent)
	sIndent = sIndent or "   "
	for k,v in pairs(tValue) do
		dbg(sIndent .. tostring(k) .. ":  " .. tostring(v))
		if (type(v) == "table") then
			PrintTable(v, sIndent .. "   ")
		end
	end
end

---------------------------------------------------------------------
-- Timer Handling
---------------------------------------------------------------------
function OnTimerExpired(idTimer)
	if (idTimer == g_DirectorInitializedTimer) then
		DirectorInitialized()
		g_DirectorInitializedTimer = C4:KillTimer(idTimer)
     elseif(idTimer == DriverHelper.VolUpTimer) then
			local cmd = '{"action":"action.volume.stepbychange","flag":1}'
			ProxyHelper.SendCommand(cmd)
     elseif(idTimer == DriverHelper.VolDownTimer) then
	     local cmd = '{"action":"action.volume.stepbychange","flag":0}'
	     ProxyHelper.SendCommand(cmd)
     elseif(idTimer == DriverHelper.UpdateMediaInfo) then
	   g_LocalMusic = ProxyHelper.ReadInfo("localmusic")
	   g_CollectedBoards = ProxyHelper.ReadInfo("CollectedBoards")
	   g_CollectedRadios = ProxyHelper.ReadInfo("CollectedRadios")
	   g_songlist = ProxyHelper.ReadInfo("songlist")
	   build_MediaByKeyTable(g_CollectedRadios)
	   build_MediaByKeyTable(g_LocalMusic)
     elseif(idTimer == DriverHelper.Reconnect) then
	   		--if(gConnectStatus == "OFFLINE") then
	   			--ProxyHelper.ConnectServer()
	   		--end
	   
     elseif(idTimer == DriverHelper.CheckScan ) then
		  if(gCurrentScan == 8) then
			 gCurrentScan = 0
			 DriverHelper.CheckScan = DriverHelper.KillTimer(DriverHelper.CheckScan)
		  elseif(gCurrentScan <8) then
			 ProxyHelper.GetNextMediaLib(gCurrentScan)	
		  end
		
	else
		print('DESTROYING STRAY TIMER: ' .. idTimer)
		C4:KillTimer(idTimer)
	end
end

function DriverHelper.AddTimer(timer, count, units, recur)
	local newTimer
	if (recur == nil) then recur = false end
	if (timer and timer ~= 0) then DriverHelper.KillTimer (timer) end

	newTimer = C4:AddTimer (count, units, recur)
	return newTimer
end

function DriverHelper.KillAllTimers()
	for k,v in pairs (DriverHelper or {}) do
		if (type (v) == 'number') then
			DriverHelper[k] = DriverHelper.KillTimer (DriverHelper[k])
		end
	end
end

function DriverHelper.KillTimer(timer)
	if (timer and type (timer) == 'number') then
		return (C4:KillTimer (timer))
	else
		return (0)
	end
end

---------------------------------------------------------------------
-- Now Playing
---------------------------------------------------------------------

function GetNodesByPath(xml, path)
	-- This function returns all nodes matching this path
	local ret = {}
	if (xml.ChildNodes ~= nil) then
		local found = string.find(path, "/", 1, true)
		if (found ~= nil) then
			local name = string.sub(path, 1, found - 1)
			for i,v in pairs(xml.ChildNodes) do
				local node = v
				if (node.Name == name) then
					local nodes = GetNodesByPath(node, string.sub(path, found + 1))
					if (nodes ~= nil) then
						for j,w in pairs(nodes) do
							table.insert(ret, w)
						end
					end
				end
			end
		else
			for i,v in pairs(xml.ChildNodes) do
				if (v.Name == path) then
					table.insert(ret, v)
				end
			end
		end
	end
	return ret
end

function GetNodeValueByPath(xml, path)
	-- This function assumes that only one node with the path exists and returns its value
	for i,v in pairs(GetNodesByPath(xml, path)) do
		return v.Value
	end
end

function GetNodesValuesByPath(xml, path)
	-- This function returns all values of all nodes with this path
	local ret = {}
	for i,v in pairs(GetNodesByPath(xml, path)) do
		table.insert(ret, v.Value)
	end
	return ret
end

function GetQueueFromRoom(map, roomId)
	roomId = tostring(roomId)
	-- This function queries digital audio for the room/queue map to figure out what
	-- queue id is used by a room
	--print("map::"..map)
	if (map == nil) then
		map = g_roomMapInfo
	end
	if (map ~= nil) and (map ~= "") then
		local info = C4:ParseXml(map)
		if (info ~= nil) then
			for i,v in pairs(GetNodesByPath(info, "audioQueueInfo/queue")) do	
				local queueId = tonumber(GetNodeValueByPath(v, "id"))		
				for j,w in pairs(GetNodesValuesByPath(v, "rooms/id")) do		
					if (w == roomId) then				
						return queueId
					end
				end
			end
		end
	end
	
	return 0
end

function GetRoomsByQueue(map, queueId)
	-- This function returns an array of room ids in a given queue
	if (map == nil) then
		map = g_roomMapInfo
	end
	
	if (map ~= nil) and (string.len(map) > 0) then
	     print(map)
		local info = C4:ParseXml(map)
		if (info ~= nil) then
			for i,v in pairs(GetNodesByPath(info, "audioQueueInfo/queue")) do
				local id = tonumber(GetNodeValueByPath(v, "id"))
				if (id == queueId) then
					local rooms = {}
					for j,w in pairs(GetNodesValuesByPath(v, "rooms/id")) do
						table.insert(rooms, w)
					end
					return rooms
				end
			end
		end
	end
end

function DashboardChanged(state)
	local ids = nil
	if (state == "PLAY") then
		ids = "SkipRev Pause SkipFwd"
	elseif ((state == "PAUSE") or (state == "STOP")) then
		ids = "SkipRev Play SkipFwd"
	elseif (state == "END") then
		ids = "SkipRev Pause SkipFwd"		
	else
		ids = ""
	end
	local args = {}
	args["Items"] = ids
	BroadcastEvent(GENERIC_MEDIA_PROXY_BINDING_ID, "DashboardChanged", args)
end

function ChangeDashboard(queueInfo, newState)
	local dashboard = GetDashboardByState(newState)
end

function GetDashboardByState(state)
	if (state == "PLAY") then
		return "SkipRev Pause SkipFwd"
	elseif ((state == "PAUSE") or (state == "STOP")) then
		return "SkipRev Play SkipFwd"
	elseif (state == "END") then
		return "SkipRev Pause SkipFwd"		
	else
		return ""
	end
end

---------------------------------------------------------------------
-- Property Handling
---------------------------------------------------------------------
function OnPropertyChanged(strProperty)
	dbg("OnPropertyChanged(" .. strProperty .. ") changed to: " .. Properties[strProperty])
	local propVal = Properties[strProperty]
	 if(strProperty == "Debug Mode") then
	   DEBUGMODE = (propVal == "true")
	   
	   C4:AllowExecute(DEBUGMODE)
     end
	
end

---------------------------------------------------------------------
-- Room Mapping
---------------------------------------------------------------------
g_roomMapInfo = nil
function OnWatchedVariableChanged(idDevice, idVariable, strValue)
	dbg("idDevice: "..idDevice.." idVariable: "..idVariable.." strValue: "..strValue)
	if ((idDevice == 100002) and (idVariable == 1031)) then
		-- Update the room map
		local oldMap = g_roomMapInfo
		g_roomMapInfo = strValue
		--local _, _,g_queueId = string.find(g_roomMapInfo, "<id>(.-)</id>");
		--Navigator:OnUpdatedRoomMapInfo(oldMap, strValue)
	elseif (idVariable == 1031 and idDevice == g_RoomID) then
			  local _, _, deviceID = string.find(strValue, "<deviceid>(.-)</deviceid>")
			  deviceID = tonumber(deviceID)
			  if(deviceID == 100002) then
				  	print("CONTROL4 DIGITAL MUSIC IS SELECTED")
				  	--local cmd = '{"action":"action.aux.switch","openAux":true}'
				  	--ProxyHelper.SendCommand(cmd)
			  elseif(deviceID == C4:GetDeviceID()+1) then	
				  	print("device music is SELECTED")
				  	--local cmd = '{"action":"action.aux.switch","openAux":false}'
				  	--ProxyHelper.SendCommand(cmd)
			  end
	end
end



--------------------UI END----------------------------------


------------------- Initialization ---------------------
function OnDriverInit()
	-- room uses the proxy for lookups - use the proxy device id for items
	local proxyDev = C4:GetProxyDevices()
	if (proxyDev) then
		C4:MediaSetDeviceContext(proxyDev)
	end

    
end	


function OnDriverUpdate()
	-- room uses the proxy for lookups - use the proxy device id for items
	local proxyDev = C4:GetProxyDevices()
	if (proxyDev) then
		C4:MediaSetDeviceContext(proxyDev)
	end
	OnPropertyChanged("IP Address")
end	


function OnDriverLateInit()
    --ProxyHelper.ConnectServer()
     g_LocalMusic = ProxyHelper.ReadInfo("localmusic")
	g_CollectedBoards = ProxyHelper.ReadInfo("CollectedBoards")
	g_CollectedRadios = ProxyHelper.ReadInfo("CollectedRadios")
	g_songlist = ProxyHelper.ReadInfo("songlist")
	build_MediaByKeyTable(g_CollectedRadios)
	build_MediaByKeyTable(g_LocalMusic)
	C4:UpdateProperty("Driver Version",g_DriverVersion)
	
end

function OnDriverRemovedFromproject()
    C4:DestroyServer()
end

for k,v in pairs(Properties) do
	OnPropertyChanged(k)
end

function DirectorInitialized()
	local room = C4:GetBoundConsumerDevices(C4:GetDeviceID()+2, 7001)
			if (room ~= nil) then
				for k, v in pairs(room) do
					print(v.." with id "..k)
					C4:RegisterVariableListener(k, 1031)
					g_RoomID = k
				end
			end
	g_roomMapInfo = C4:GetVariable(100002, 1009)
	C4:RegisterVariableListener(100002, 1009) 
	--C4:RegisterVariableListener(100002, 1009) -- Watch digital audio's room map variable
end
g_DirectorInitializedTimer = C4:AddTimer(20, "MILLISECONDS") -- Fire as soon as possible
SendCommandTimer = C4:SetTimer(4000, function(timer, skips) ProxyHelper.SendCommandList() end, true)


