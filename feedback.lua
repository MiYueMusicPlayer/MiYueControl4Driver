--播放器反馈数据处理
-- Untitled.lua
--
gCurrentVolume = 0
tmpQueue = ""
function ParseFeedback(strData)
	-- body

	--print("Begin to Parse DATA" .. strData)
 	
	local response = json:decode(strData)
	ProxyHelper.TCPReceiveBuf = ""

	if(response.result == 400) then
		return
	end
    if(response.result == 200) then
	    local msg_id = {["action.request.getlocalMusic"] = "LocalMusic",["action.request.getradioInfo"] = "RadioInfo",
						    ["action.request.getwangyiboards"] = "CloudInfo",["action.request.boardMusicInfos"] = "BoardMusicInfos",
						    ["action.request.collectedMusic"] = "GetcollectedMusic",["action.request.collectedBoards"] = "GetcollectedBoards",
						    ["action.request.collectedRadios"] = "GetcollectedRadios",["action.request.collectedSonglist"] = "GetcollectedSonglist",["action.douban.getdirinfos"] = "GetDouban"}
	   if(type(ParseMessage[msg_id[response.action]]) == "function") then
	   
		  ParseMessage[msg_id[response.action]](response)
		  
	   end
	   
	   if(response.action == "action.response.localMusicChanged") then
		  ProxyHelper.GetNextMediaLib(1)
	   end
	   
	   if(response.action == "action.response.netMusicUpdateComplete") then
		  ProxyHelper.Scan()
	   end
	   
	   if(response.action == "action.response.currentMusicList") then
		  print("get gonowplianghsdasdas")
			   --local Nowplaylist = {}
		   if (gNowPlaying[1] ~= nil) then
			   gNowPlaying = {} 
				    --gCurrentSongIndex = 1	
		   end
		   
		   for k,v in pairs(response.infos) do 
			  gNowPlaying[k] = {Title = v.title,fileName = v.fileName,songSrc = v.songSrc,singer = v.singer,ImageUrl = v.pic,songId = v.songId,fileUrl = v.fileUrl,Id = k-1}
		   end
		   
		    
       end
    
    
	   
	    if(response.action == "action.response.playerposition") then
	         local volume = math.floor(tonumber(response.volumeValue))
		    if(gCurrentVolume ~= volume) then
				--UpdateVolume(gCurrentVolume)
				gCurrentVolume = volume
				UpdateVolume(gCurrentVolume)
		    end
		    local SongTitle = response.info.title
		    if(response.isPlaying) then
				if(SongTitle ~= gCurrentSongTitle) then
				    gCurrentSongTitle = SongTitle
				    
				    if(gNowPlaying == nil) then
					   GetNowplayList() 	
				    end
				    for k,v in pairs(gNowPlaying) do
					   if(gCurrentSongTitle == v.Title) then
							 gCurrentSongIndex = k
					   end
				    end
				    UpdateMediaInfo(5001,gNowPlaying[gCurrentSongIndex].Title,gNowPlaying[gCurrentSongIndex].singer,"","",gNowPlaying[gCurrentSongIndex].ImageUrl,g_RoomID,"secondary", "True")
				    local data = CacheNowPlaying()
				    QueueChanged(5001, nil, g_RoomID, data)
				    
			     end
			    if(gQueues["STATE"] ~= "PLAY") then
				    DashboardChanged("PLAY")
				    gQueues["STATE"] = "PLAY"
			    end
			    
				 
			    --进度条
			   --[[ local duration = tonumber(response.info.duration)
			    local position = tonumber(response.position)
			    if(duration >0 and position >0) then
			   -- print(tonumber(response.position))
				    UpdateProgress (duration,position)
			   else
				duration = 0
				position = 0
				UpdateProgress (duration,position)
			   end]]--
			 else
				DashboardChanged("PAUSE")
				gQueues["STATE"] = "PAUSE"
				--gCurrentSongTitle = ""
		    end
	   
	   elseif(response.action == "action.request.musiclist") then
		  
			   --local Nowplaylist = {}
		   if (gNowPlaying[1] ~= nil) then
			   gNowPlaying = {} 
				    --gCurrentSongIndex = 1	
		   end
		   
		   for k,v in pairs(response.infos) do 
			  gNowPlaying[k] = {Title = v.title,fileName = v.fileName,songSrc = v.songSrc,singer = v.singer,ImageUrl = v.pic,songId = v.songId,fileUrl = v.fileUrl,Id = k-1}
			
			  if(gCurrentSongTitle == v.title) then
				gCurrentSongIndex = k
			  end
		   end
		   
		    UpdateMediaInfo(5001,gNowPlaying[gCurrentSongIndex].Title,gNowPlaying[gCurrentSongIndex].singer,"","",gNowPlaying[gCurrentSongIndex].ImageUrl,g_RoomID,"secondary", "True")
		   
		   local data = CacheNowPlaying()
		   QueueChanged(5001, nil, g_RoomID, data)
		  
	   
	   elseif(response.action == "action.collect.musics") then
	   
			 ProxyHelper.GetNextMediaLib(5)
			 
       elseif(response.action == "action.response.collectDataChanged") then
			 local flag = tonumber(response.flag)
			 if(flag == -1) then
				ProxyHelper.GetNextMediaLib(5)
			 elseif(flag == -2) then
				ProxyHelper.GetNextMediaLib(7)
			 elseif(flag == -3) then
				ProxyHelper.GetNextMediaLib(6)
			 elseif(flag == -4) then
				ProxyHelper.GetNextMediaLib(8)
			 elseif(flag >0) then
				ProxyHelper.GetNextMediaLib(8)
			 end
			 
        elseif(response.action == "action.request.getVolume") then
		    gCurrentVolume = math.floor(tonumber(response.volumeValue))
		    UpdateVolume(gCurrentVolume)
	   elseif(response.action == "action.request.changeVolume") then
		    GetCurrentVolume()
	   end
	   
		 
    end
end


function CacheNowPlaying()
    local queue = {}
		  -- print("gNOWPLAYING IS :" .. #gNowPlaying)
				    if(#gNowPlaying < 6) then
					    
					    for i = 1, #gNowPlaying do
						  --gNowPlaying[gCurrentSongIndex + i -1].ImageUrl = nil
						  queue[i] = gNowPlaying[gCurrentSongIndex + i -1]
					    end
				    else
					   for i = 1, 5 do
						 -- gNowPlaying[gCurrentSongIndex + i -1].ImageUrl = nil
						  queue[i] = gNowPlaying[gCurrentSongIndex + i -1]
					    end
				    end
			    -- print("queue leng is " ..#queue
				 --PrintTable(queue)
				    
					   if(#queue > 1) then
						  
						  table.insert(queue,1,{Title = 'Now Playing', isHeader = "true"})
						  table.insert(queue,3,{Title = 'Up Next', isHeader = "true"})
					   else
						  table.insert(queue,1,{Title = 'Now Playing', isHeader = "true"})
					   end
					   
					   
					   local List = BuildListXml(queue,true)
					   local NowPlayingIndex = BuildSimpleXml(nil, {["NowPlayingIndex"] = gCurrentSongIndex -1})
					   local data = NowPlayingIndex .. List
					   tmpQueue = data
					   
					   return tmpQueue
end