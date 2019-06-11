--
-- Untitled.lua
--

--处理编程选项

function GetLocalMusic()
     local list ={}
    for i = 1, #g_LocalMusic do
	   table.insert(list,g_LocalMusic[i].title)
    end
    return list
end

function GetPlayList()
     local list ={}
    for i = 1, #g_songlist do
	   table.insert(list,g_songlist[i].songlistTitle)
    end
    return list
end

function GetBoards()
     local list ={}
    for i = 1, #g_CollectedBoards do
	   table.insert(list,g_CollectedBoards[i].songlistTitle)
    end
    return list
end

function GetRadios()
     local list ={}
    for i = 1, #g_CollectedRadios do
	   table.insert(list,g_CollectedRadios[i].title)
    end
    return list
end

--------Actions--------
function ExecuteCommand(strCommand, tParams)
	print("ExecuteCommand function called with : " .. strCommand)
	if (tParams ~= nil) then
		PrintTable(tParams)
	end
	if (strCommand == "LUA_ACTION") then
		for cmd,cmdv in pairs(tParams) do
			if cmd == "ACTION" then
				if (cmdv == "Scan") then
				    ProxyHelper.Scan()
				end
			else
				
			end
		end
	elseif(strCommand == "SelectLocalmusic") then
		  SendPlayCommand(tParams.LocalMusic)
	elseif(strCommand == "SelectPlayList") then
		   for k,v in pairs(g_songlist) do
			 if(v.songlistTitle == tParams.PlayList) then
			 
				SendPlaylistCommand(v.id)
			 end
		  end
	elseif(strCommand == "SelectBoards") then
		  for k,v in pairs(g_CollectedBoards) do
			 if(v.songlistTitle == tParams.Boards) then
			 
				SendPlaylistCommand(v.id)
			 end
		  end
	elseif(strCommand == "SelectRadios") then
		 SendPlayCommand(tParams.Radios)
     elseif(strCommand == "AUX") then
		  if(tParams.AUX == "ON") then
		     print("turn on aux")
		  local cmd = '{"action":"action.aux.switch","openAux":true}'
		  ProxyHelper.SendCommand(cmd)
		  else
		  local cmd = '{"action":"action.aux.switch","openAux":false}'
		  ProxyHelper.SendCommand(cmd)
		  end
     elseif(strCommand == "BLUETOOTH") then
		  if(tParams.Bluetooth == "ON") then
		      local cmd = '{"action":"action.bluetooth.switch","openBluetooth":true}'
			 ProxyHelper.SendCommand(cmd)
		  else
			 local cmd = '{"action":"action.bluetooth.switch","openBluetooth":false}'
			 ProxyHelper.SendCommand(cmd)
		  end
     elseif(strCommand == "SPDIF") then
		  if(tParams.SPDIF == "ON") then
		      local cmd = '{"action":"action.spdif.switch","openSpdif":true}'
			 ProxyHelper.SendCommand(cmd)
		  else
		      local cmd = '{"action":"action.spdif.switch","openSpdif":false}'
			 ProxyHelper.SendCommand(cmd)
	       end
     elseif(strCommand == "PLAY MODE") then
	       local message = nil
		  if(tParams.PlayMode == "Repeat") then
			  message  = '{"action": "action.request.switchplaytype","playType": 0}'
			 --ProxyHelper.SendCommand(message)
		  
		  elseif(tParams.PlayMode == "Shuffle") then
			  message  = '{"action": "action.request.switchplaytype","playType": 2}'
			 --ProxyHelper.SendCommand(message)
		  elseif(tParams.PlayMode == "Single cycle") then
			  message  = '{"action": "action.request.switchplaytype","playType": 1}'
		  else
			 message  = '{"action": "action.request.switchplaytype","playType": 3}'
	
		  end
		  ProxyHelper.SendCommand(message)
--Single cycle
		  
	end	
end

function SendPlayCommand(key)
     local data = json:encode(g_MediaByKey[key])
		  data = '{"action": "action.request.music","infos":[' ..data .. "]}"
		  ProxyHelper.SendCommand(data)
end

function SendPlaylistCommand(id)
   local cmd = '{"action":"action.play.songlist","id":'.. id ..',"musicIndex":0}'
   ProxyHelper.SendCommand(cmd)
end
