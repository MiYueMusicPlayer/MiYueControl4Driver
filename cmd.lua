--所有的命令调用对外发送和协议内的命令实现

PRX_CMD = {}

function PRX_CMD.AddToFavorites(idBinding,tParams) --添加收藏
    local args = ParseProxyCommandArgs(tParams)
    if(tonumber(args.songSrc) == 8 or tonumber(args.songSrc) == 5 ) then
	     message = '{"action":"action.collect.radios","id":'..args.IndexID.."}"
	   
    else
	   message = json:encode(g_MediaByKey[args.key])
		    --print(data)
	   message = '{"action": "action.collect.musics","infos":[' ..message .. "]}"
    end
    ProxyHelper.SendCommand(message)
    --ProxyHelper.GetNextMediaLib(6)
end
--重要维护对象，页面
function PRX_CMD.GetBrowseStationsMenu(idBinding, tParams) --浏览
	--print("GetBrowseStationsMenu (" .. idBinding .. ", " .. tParams.SEQ .. ") for nav " .. tParams.NAVID)
	local args = ParseProxyCommandArgs(tParams)

	local tListItems = {}
	local url
	local isRootMenu = false
	local screen = args.screen
	local key = args.key
	
	
		if (key == "radio") then
			BrowseRadioList(idBinding,tParams)
		elseif (key == "local")	then
			BrowseLocalMusic(idBinding,tParams)
		elseif (key == "wangyi")	then		
			BrowseWangYiYun(idBinding,tParams)
		elseif(key == "douban") then
			 BrowseDouban(idBinding,tParams)
		elseif(key == "blue") then
		elseif(key == nil) then
			tListItems = g_browse_mainmenu
			DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], tListItems)
	     else
		  g_selectboardsid = key
		  g_currentboards = args.text
		  BrowseBoardMusicInfos(idBinding,tParams,key)
		  
		  
		end
		

	
	
end 

function PRX_CMD.GetBrowseFavoritesMenu(idBinding, tParams) --收藏
   -- print("GetBrowseStationsMenu (" .. idBinding .. ", " .. tParams.SEQ .. ") for nav " .. tParams.NAVID)
	local args = ParseProxyCommandArgs(tParams)

	local tListItems = {}
	local url
	local isRootMenu = false
	local screen = args.screen
	local key = args.key
	
	
		if (key == "local") then
			BrowseCollectedMusic(idBinding,tParams)
		elseif (key == "songlist") then
		     BrowseCollectedSonglist(idBinding,tParams)
			
		elseif (key == "boards")	then
		     --ProxyHelper.GetNextMediaLib(5)
			BrowseCollectedBoards(idBinding,tParams)
	     elseif(key == "radios") then
			 BrowseCollectedRadios(idBinding,tParams)
		elseif(key == nil) then
			tListItems = g_browse_music
			DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], tListItems)
	     else
			 g_selectboardsid = key
			 BrowseBoardMusicInfos(idBinding,tParams,key)
			
		end
		

	
end


function PRX_CMD.BrowseStationsCommand(idBinding, tParams)	--二级页面浏览实现
	local args = ParseProxyCommandArgs(tParams)
	local tResponse = {}
	local nextscreen
	if(args.type == "link") then
	
	    nextscreen = "<NextScreen>BrowseStations</NextScreen>"
	    DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	    g_key = args.key
     elseif(args.type == "local") then
	   nextscreen = "<NextScreen>BrowseLocalMusic</NextScreen>"
	  -- GetNextMediaLib(1)
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key  
	 elseif(args.type == "radio") then
	   nextscreen = "<NextScreen>BrowseRadio</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
     elseif(args.type == "douban") then
	   nextscreen = "<NextScreen>BrowseDouban</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
	 elseif(args.type == "wangyiyun") then
	 	nextscreen = "<NextScreen>BrowseWangYiYun</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
	   
     end
	
end 


function PRX_CMD.BrowseFavoritesCommand(idBinding, tParams)--二级页面的收藏
	local args = ParseProxyCommandArgs(tParams)	
	local args = ParseProxyCommandArgs(tParams)
	local tResponse = {}
	local nextscreen
	if(args.type == "link") then
	
	    nextscreen = "<NextScreen>BrowseFavorites</NextScreen>"
	    DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	    g_key = args.key
	elseif(args.type == "cmusic") then
	   nextscreen = "<NextScreen>BrowseCollectedMusic</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
     elseif(args.type == "songlist") then
	   nextscreen = "<NextScreen>BrowseCollectedSonglist</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
     elseif(args.type == "cboards") then
	 	nextscreen = "<NextScreen>BrowseCollectedBoards</NextScreen>"
	     DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	     g_key = args.key
     elseif(args.type == "cradios") then
	   nextscreen = "<NextScreen>BrowseCollectedRadios</NextScreen>"
	   DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	   g_key = args.key
     end
end 
 
function PRX_CMD.SET_VOLUME_LEVEL(idBinding,tParams)
    local vol = tonumber(tParams.LEVEL)
    local cmd = '{"action": "action.request.changeVolume", "volumeValue":'.. vol .."}"
    ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.GetMyFavoritesMenu(idBinding, tParams)	--点击收藏文件夹
	local tFavorites = getFavorites()
	DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], tFavorites)
  
end

function PRX_CMD.GetQueue(idBinding, tParams) --获取当前列表
	gCurrentQueueRoomID = g_RoomID
	
     local data = tmpQueue

     QueueChanged(5001, nil, g_RoomID, data)
	
end 

function PRX_CMD.NowPlayingCommand(idBinding, tParams) --当前播放处选择播放歌曲
	local args = ParseProxyCommandArgs(tParams)
	--PrintTable(args)
	gCurrentSongIndex = tonumber(args.Id) + 1
	local message = '{"action": "action.request.switchMusic","musicIndex":'.. args.Id.."}"
	ProxyHelper.SendCommand(message)
    -- UpdateMediaInfo(5001,gNowPlaying[gCurrentSongIndex].Title,gNowPlaying[gCurrentSongIndex].fileName,gNowPlaying[gCurrentSongIndex].singer,gNowPlaying[gCurrentSongIndex].songSrc,gNowPlaying[gCurrentSongIndex].ImageUrl,g_RoomID,"secondary", "True")
     
end 

function PRX_CMD.ToggleRepeat()  --循环
	-- body
	REPEAT = true
	SHUFFLE = false
	local message  = '{"action": "action.request.switchplaytype","playType": 0}'
	ProxyHelper.SendCommand(message)
end

function PRX_CMD.ToggleOrder()  --循环
	-- body
	REPEAT = true
	SHUFFLE = false
	local message  = '{"action": "action.request.switchplaytype","playType": 3}'
	ProxyHelper.SendCommand(message)
end

function PRX_CMD.ToggleShuffle() --当前播放页面的打开随机播放
	
	SHUFFLE = not(SHUFFLE)
	
	local message = '{"action": "action.request.switchplaytype","playType": 2}'
	ProxyHelper.SendCommand(message)
end


function PRX_CMD.PresetCommand(idBinding, tParams) --当前播放页面的收藏按钮功能实现
	--local args = ParseProxyCommandArgs(tParams)
	--local key = args.key
	
	local message = json:encode(gNowPlaying[gCurrentSongIndex])
	
	message = '{"action": "action.collect.musics","infos":[' ..message .. "]}"
	ProxyHelper.SendCommand(message)
	--ProxyHelper.GetNextMediaLib(4)
	
end	


function PRX_CMD.START_VOL_UP(idBinding, sCommand, tParams)	--长按音量键基本不要维护
	
    DriverHelper.VolUpTimer = DriverHelper.AddTimer(DriverHelper.VolUpTimer, 500, "MILLISECONDS", true);
    
end 

function PRX_CMD.START_VOL_DOWN(idBinding, sCommand, tParams)

    DriverHelper.VolDownTimer = DriverHelper.AddTimer(DriverHelper.VolDownTimer, 500, "MILLISECONDS", true);
end 

function PRX_CMD.STOP_VOL_UP(idBinding, sCommand, tParams)	
	
		DriverHelper.VolUpTimer = DriverHelper.KillTimer(DriverHelper.VolUpTimer)
		GetCurrentVolume()
	
end

function PRX_CMD.STOP_VOL_DOWN(idBinding, sCommand, tParams)	
	
	
		DriverHelper.VolDownTimer = DriverHelper.KillTimer(DriverHelper.VolDownTimer)	
		GetCurrentVolume()
    
end

function PRX_CMD.PULSE_VOL_UP()
    --local vol = gCurrentVolume + 5
    
    local cmd = '{"action":"action.volume.stepbychange","flag":1}'
    ProxyHelper.SendCommand(cmd)
    GetCurrentVolume()
end
function PRX_CMD.PULSE_VOL_DOWN()
   -- local vol = gCurrentVolume - 5
    
    local cmd = '{"action":"action.volume.stepbychange","flag":0}'
    ProxyHelper.SendCommand(cmd)
    GetCurrentVolume()
    
end

function PRX_CMD.MUTE_ON()
    g_targevolume = gCurrentVolume
    local cmd = '{"action": "action.request.changeVolume", "volumeValue":'.. 0 .."}"
    ProxyHelper.SendCommand(cmd)
    C4:SendToProxy (5002, "MUTE_CHANGED", {MUTE = true, OUTPUT = 4001})
    C4:SendToProxy(5002, "VOLUME_LEVEL_CHANGED", {LEVEL = 0, OUTPUT = 4001})
end

function PRX_CMD.MUTE_OFF()
    local cmd = '{"action": "action.request.changeVolume", "volumeValue":'.. g_targevolume .."}"
    ProxyHelper.SendCommand(cmd)
    C4:SendToProxy (5002, "MUTE_CHANGED", {MUTE = false, OUTPUT = 4001})
    C4:SendToProxy(5002, "VOLUME_LEVEL_CHANGED", {LEVEL = g_targevolume, OUTPUT = 4001})
end

function PRX_CMD.MUTE_TOGGLE()
    if(gCurrentVolume ~= 0) then
	   PRX_CMD.MUTE_ON()
    else
	   PRX_CMD.MUTE_OFF()
    end
end

function PRX_CMD.play(idBinding, tParams)
    SendToProxy(5001, "SELECT_DEVICE", {ROOM_ID = tParams["ROOMID"]}, "COMMAND")
	local args = ParseProxyCommandArgs(tParams)
	local tResponse = {}
	local nextscreen
	
    local data = json:encode(g_MediaByKey[args.key])
    data = '{"action": "action.request.music","infos":[' ..data .. "]}"
    ProxyHelper.SendCommand(data)
    
    nextscreen = "<NextScreen>#nowplaying</NextScreen>"
	DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
		
end

function PRX_CMD.DelColletedMusic(idBinding,tParams)
	-- body
	local args = ParseProxyCommandArgs(tParams)
	local title = args.key
	local singer = args.singer
	local tmp = {title = title,singer = singer}
	local message = json:encode(tmp)
	local cmd = '{"action":"action.delete.collectedmusic","infos":[' .. message .."]}"
	ProxyHelper.SendCommand(cmd)
	--ProxyHelper.GetNextMediaLib(4)
end

function PRX_CMD.DelColletedRadios(idBinding,tParams)
	-- body
	local args = ParseProxyCommandArgs(tParams)
	local title = args.key
	--local singer = args.singer
	local tmp = {title = title}
	local message = json:encode(tmp)
	local cmd = '{"action":"action.delete.collectedradios","info":' .. message .. "}"
	ProxyHelper.SendCommand(cmd)
	--ProxyHelper.GetNextMediaLib(6)
end



function PRX_CMD.DelColletedBoards()
	local cmd = '{"action":"action.delete.collectedboards","id":'..g_selectboardsid .."}"
	ProxyHelper.SendCommand(cmd)
	--ProxyHelper.GetNextMediaLib(5)

end

function PRX_CMD.DelColletedSongList()
    local cmd = '{"action":"action.delete.songlist","id":'..g_selectboardsid.."}"
    ProxyHelper.SendCommand(cmd)
   -- ProxyHelper.GetNextMediaLib(7)
end

function PRX_CMD.AddColletedBoards()
	local cmd = '{"action":"action.collect.boards","songlistName":'..g_currentboards .."}"
	ProxyHelper.SendCommand(cmd)
	--ProxyHelper.GetNextMediaLib(5)

end

function PRX_CMD.AddToNext(idBinding,tParams)
	-- body
	local args = ParseProxyCommandArgs(tParams)
	local data = json:encode(g_MediaByKey[args.key])
	local cmd = '{"action":"action.playlist.add","flag":1,"info":' .. data .. "}"
	ProxyHelper.SendCommand(cmd)
	GetNowplayList()
end

function PRX_CMD.AddToQueue(idBinding,tParams)
	-- body
	local args = ParseProxyCommandArgs(tParams)
	local data = json:encode(g_MediaByKey[args.key])
	local cmd = '{"action":"action.playlist.add","flag":0,"info":' .. data .. "}"
	ProxyHelper.SendCommand(cmd)
	GetNowplayList() 	
end

function PRX_CMD.ReplacePlaylist(idBinding,tParams)
	-- body
	local args = ParseProxyCommandArgs(tParams)
	local id = 0
	local cmd = ""
	if(args.listtype == "CollectedMusic") then
		id = -1
		cmd = '{"action":"action.play.songlist","id":'.. id ..',"musicIndex":0}'
	
    elseif(args.listtype == "localmusic") then
    
	   cmd =  '{"action":"action.play.localmusic","musicIndex":'.. args.indexID .. "}"
    
    else
	    --print(g_selectboardsid)
	    id = g_selectboardsid
	    for k,v in pairs(g_currentlist) do
		  if(v.title == args.key) then
		      musicindex = k-1
		  end
	   end
	    cmd = '{"action":"action.play.songlist","id":'.. id ..',"musicIndex":'..musicindex..'}'
      end

	
	ProxyHelper.SendCommand(cmd)
	-- SendToProxy(5001, "SELECT_DEVICE", {ROOM_ID = tParams["ROOMID"]}, "COMMAND")
	nextscreen = "<NextScreen>#nowplaying</NextScreen>"
	DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], nextscreen)
	 
	 

end

function PRX_CMD.Addtosongsheet(idBinding, tParams)
     local args = ParseProxyCommandArgs(tParams)
	local tResponse = {}
	local nextscreen
	local message = json:encode(g_MediaByKey[args.key])
	local cmd = '{"action": "action.collect.musics","infos":[' ..message .. "]}"
	ProxyHelper.SendCommand(cmd)
end




function PRX_CMD.DESTROY_NAV(idBinding, tParams)
	local queueId = GetQueueFromRoom(nil, tParams.ROOMID) 
	ClearNowPlayingQueue(queueId)
end

function PRX_CMD.PLAY(idBinding, tParams)	
	local ids = "PLAY"
	DashboardChanged( ids)
	local cmd = '{"action": "action.request.playorpause","message": "play"}'
	ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.PAUSE(idBinding, tParams)
     print("pause is be push")
	local ids = "PAUSE"
	DashboardChanged(ids)
	local cmd = '{"action": "action.request.playorpause","message": "pause"}'
	ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.OFF(idBinding, tParams)
	
		PRX_CMD.PAUSE(5001, {ROOM_ID = g_RoomID})
		print("Shut down player here")
		gQueues["STATE"] = "PAUSE"
		gCurrentSongTitle = ""
end 


function PRX_CMD.TransportSkipRevButton(idBinding, tParams)
	--SKIP_REV
	
	local cmd = '{"action": "action.request.switchMusic","message": "before"}'
	ProxyHelper.SendCommand(cmd)
end


function PRX_CMD.TransportSkipFwdButton(idBinding, tParams)
	--SKIP_FWD
	local cmd = '{"action": "action.request.switchMusic","message": "next"}'
	ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.SKIP_REV()
    local cmd = '{"action": "action.request.switchMusic","message": "before"}'
	ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.SKIP_FWD()
    local cmd = '{"action": "action.request.switchMusic","message": "next"}'
	ProxyHelper.SendCommand(cmd)
end

function PRX_CMD.QUEUE_STATE_CHANGED(idBinding, tParams)
	-- This is a notification that we receive when the queue state changed
	local queueId = tonumber(tParams["QUEUE_ID"])
	local state = tParams["STATE"]
	local prevState = tParams["PREV_STATE"]
	local prevStateTime = tonumber(tParams["PREV_STATE_TIME"])
	local mediaId = tParams["QUEUE_INFO"]
	
	print("PRX_CMD.QUEUE_STATE_CHANGED() for queue " .. queueId .. ": " .. prevState .. " (" .. prevStateTime .. " seconds) -> " .. state .. " Station: " .. mediaId)	
	
	local queueInfo = gQueues[queueId]
	if (queueInfo ~= nil) then
		queueInfo["STATE"] = state
		
		if (prevState == "PLAY") then
			-- Save the current time when this station stopped playing for reporting purposes
			queueInfo["END_TIME"] = os.time()
		end
	end
	
	if (queueInfo ~= nil) then
		ChangeDashboard(queueInfo, state)
	end
	
	if ((state == "END") and (gCurrentSongIndex ~= #gNowPlaying)) then
		gCurrentSongIndex = gCurrentSongIndex + 1
		NowPlayingChanged(idBinding, tParams)
	end	
	
end

function PRX_CMD.QUEUE_DELETED(idBinding, tParams)
	-- This is a notification that we receive when the queue gets deleted
	local queueId = tonumber(tParams["QUEUE_ID"])
	local lastQueueState = tParams["LAST_STATE"]
	local lastQueueStateTime = tonumber(tParams["LAST_STATE_TIME"])

	print("PRX_CMD.QUEUE_DELETED() for queue " .. queueId .. ", last state was " .. lastQueueState .. " for " .. lastQueueStateTime .. " seconds")
	
	local queueInfo = gQueues[queueId]
	if (queueInfo ~= nil) then
		print("Deleting queue info for queue " .. queueId .. ", was playing QUEUE_INFO " .. tParams["QUEUE_INFO"])
		
		ChangeDashboard(queueInfo, nil) -- Clear the media dashboard
		
		if (lastQueueState == "PLAY") then
			-- Save the current time when this station stopped playing for reporting purposes
			queueInfo["END_TIME"] = os.time()
		end
		
		gQueues[queueId] = nil
		queueInfo = nil
		
		ClearNowPlayingQueue(queueId)
	end
	
end

function PRX_CMD.QUEUE_MEDIA_INFO_UPDATED(idBinding, tParams)
    --print("22222222222222222222222222222")
end

function PRX_CMD.GetDashboard(idBinding, tParams)
	-- This is called when navigators want to know the dashboard controls to be displayed.
	if (gQueues.STATE ~= nil) then
		DashboardChanged(gQueues["STATE"])
	else
		DashboardChanged("")
	end
end

function PRX_CMD.GetSettings(idBinding, tParams)
	print("PRX_CMD.GetSettings(" .. idBinding .. ", " .. tParams.SEQ .. ") for nav " .. tParams.NAVID)
	local settings = {}
	settings.IP = g_ServerIPAddress
	settings.Status = Properties["Connection Status"]
	settings.scan = Properties["Scan Progress"]
	local data = BuildSimpleXml("Settings", settings, true)
	DataReceived(idBinding, tParams["NAVID"], tParams["SEQ"], data)	
	
end



function PRX_CMD.SettingChanged(idBinding, tParams)
	local args = ParseProxyCommandArgs(tParams)
	print("PRX_CMD.SettingChanged (" .. idBinding .. ", " .. tParams.SEQ .. ") for nav " .. tParams.NAVID)
	if(args.PropertyName == "ToggleButton") then
	   if(args.Value == "on") then
		  print("turn on aux")
		  local cmd = '{"action":"action.aux.switch","openAux":true}'
		  ProxyHelper.SendCommand(cmd)
	   else
		  print("turn off aux")
		  local cmd = '{"action":"action.aux.switch","openAux":false}'
		  ProxyHelper.SendCommand(cmd)
	   end
    elseif(args.PropertyName == "CheckBox") then
	   if(args.Value == "on") then
		  print("turn on blue")
		  local cmd = '{"action":"action.bluetooth.switch","openBluetooth":true}'
		  ProxyHelper.SendCommand(cmd)
	   else
		  print("turn off blue")
		  local cmd = '{"action":"action.bluetooth.switch","openBluetooth":false}'
		  ProxyHelper.SendCommand(cmd)
	   end
	   
    elseif(args.PropertyName == "SPDIF") then

		  if(args.Value == "on") then
		      local cmd = '{"action":"action.spdif.switch","openSpdif":true}'
			 ProxyHelper.SendCommand(cmd)
		  else
		      local cmd = '{"action":"action.spdif.switch","openSpdif":false}'
			 ProxyHelper.SendCommand(cmd)
	       end
    end
end

function PRX_CMD.SubmitButtonCommand(idBinding, tParams)
	--local message = table.concat(out_table, "\n")
	local tArgs = {}
	tArgs["Id"] = "SettingsNotification"
	tArgs["Title"] = "正在扫描媒体库"
	tArgs["Message"] = "正在扫描媒体库，大约需要五分钟，请稍等。。。。"
	tParams["EVTARGS"] = BuildSimpleXml(nil, tArgs, true)
	tParams["NAME"] = "DriverNotification"
	SendToProxy(idBinding, "SEND_EVENT", tParams, "COMMAND")	
	ProxyHelper.Scan()
	
end

function PRX_CMD.localScan(idBinding, tParams)
	--local message = table.concat(out_table, "\n")
	ProxyHelper.GetNextMediaLib(1)
	
end


--- Audio cmd
function PRX_CMD.SET_INPUT(idBinding, tParams)	
	C4:SendToProxy(5002, "INPUT_OUTPUT_CHANGED", {INPUT = tParams.INPUT, OUTPUT = tParams.OUTPUT})
end 

function PRX_CMD.DISCONNECT_OUTPUT(idBinding, tParams)
	C4:SendToProxy(5002, "INPUT_OUTPUT_CHANGED", {INPUT = -1, OUTPUT = tParams.OUTPUT})
end 


function PRX_CMD.BINDING_CHANGE_ACTION(idBinding, tParams)
	local id = tonumber(tParams.BINDING_ID)
	local flag = tParams.IS_BOUND
	if (id == 7001) then			--Room connection id
		if (flag) then
			local room = C4:GetBoundConsumerDevices(C4:GetDeviceID()+2, 7001)
			if (room ~= nil) then
				for k, v in pairs(room) do
					print(v.." with id "..k)
					C4:RegisterVariableListener(k, 1031)
					g_RoomID = k
				end
			end
		end
	end
end

function PRX_CMD.GET_AUDIO_PATH(idBinding,tParams)
    for k,v in pairs(tParams) do
	   print(k,v)
    end
end

function PRX_CMD.GET_AUDIO_DEVICES(idBinding,tParams)
    print("GETAUDIODEVICE:")
    for k,v in pairs(tParams) do
	   print(k,v)
    end
end


function PRX_CMD.SELECT_SOURCE(idBinding,tParams)
    
end