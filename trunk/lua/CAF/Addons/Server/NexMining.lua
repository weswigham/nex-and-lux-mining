--[[ Serverside Custom Addon file Base ]]--

local RD = {}

require("datastream")
/*
	The Constructor for this Custom Addon Class
*/

local status = false
local startingnum = 10 --on average, on a map with only 1 planet, 6 out of 10 hit (even with 50 tries)

function RD.__Construct()
	if status then return true, "Already Active!" end
	if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then return false, "Resource Distribution is Required and needs to be Active!" end
	
	for i=1,startingnum do
		local tbl = RD.FindRandGroundPos(math.random(50,200),1,{Type="liquid nex",Depth=math.random(20,40),Ammount=math.random(20000,30000)})
		for k,v in pairs(player.GetAll()) do
			RD.SendPosDataToClient(v,tbl.pos)
		end
	end
	status = true
	return true , "Nex Mining Activated"
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	if not status then return false, "Addon is already disabled!" end
	status = false
	return true
end

/**
	Get the required Addons for this Addon Class
*/
function RD.GetRequiredAddons()
	return {"Resource Distribution"}
end

/**
	Get the Boolean Status from this Addon Class
*/
function RD.GetStatus()
	return status
end

/**
	Get the Version of this Custom Addon Class
*/
function RD.GetVersion()
	return 0.1, "Alpha"
end

/**
	Get any custom options this Custom Addon Class might have
*/
function RD.GetExtraOptions()
	return {}
end

/**
	Get the Custom String Status from this Addon Class
*/
function RD.GetCustomStatus()
	local str
	if status == true then
		str = "Nex Mining Online"
	else
		str = "Nem Mining Offline"
	end
	return str
end

/**
	You can send all the files from here that you want to add to send to the client
*/
function RD.AddResourcesToSend()
	resource.AddFile("materials/lux/lux_particle1.vmt")
	resource.AddFile("materials/lux/lux_particle1.vtf")
	resource.AddFile("materials/nex/nex_particle1.vmt")
	resource.AddFile("materials/nex/nex_particle1.vtf")
end

CAF.RegisterAddon("Nex Mining", RD, "2") 

local positions = {}
function RD.SetPositionValue(pos,radius,priority,value)
		positions[tostring(pos)] = {}
		positions[tostring(pos)].pos = pos
		positions[tostring(pos)].radius = radius
		positions[tostring(pos)].priority = priority
		positions[tostring(pos)].value = value
		return positions[tostring(pos)]
end

function RD.ClearPosition(pos)
	if positions[tostring(pos)] then positions[tostring(pos)] = nil end
	local rp = RecipientFilter()
	for k,pl in pairs(player.GetAll()) do
		if pl.NexEnabled and pl.NexEnabled == true then
			rp:Addlayer(pl)
		end
	end
	umsg.Start("RemovePosDataClientside",rp)
	umsg.Vector(pos)
	umsg.End()
end

function RD.GetPosValue(pos)
	if positions[tostring(pos)] then return positions[tostring(pos)] end
	local returnval = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= v.radius then
			if returnval and (returnval != nil) then 
				if v.priority > returnval.priority then
					returnval = v
				end
			else
				returnval = v
			end
		end
	end
	return returnval
end

function RD.GetNearestPos(pos)
	if positions[tostring(pos)] then return positions[tostring(pos)] end
	local dist = 999999999999999999
	local out = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= dist then 
			dist = v.pos:Distance(pos) 
			out = v
		end
	end
	return out
end

function RD.GetNearestPosWithValue(pos,value)
	if positions[tostring(pos)] and positions[tostring(pos)].value == value then return positions[tostring(pos)] end
	local dist = 999999999999999999
	local out = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= dist and v.value == value then 
			dist = v.pos:Distance(pos) 
			out = v
		end
	end
	return out
end

function RD.GetAllPositions()
	return positions
end

function RD.GetAllPositionsString()
	local sanitizd = table.Sanitise(positions)
	local strg = util.TableToKeyValues(sanitizd)
	return strg
end 
--[[
function RD.SendPosDataToClient(ply,pos) --mm...debating weather it should send value or not...perhaps ifit's not a table...and priority shouldn't be needed clientside...so...
	if not ply.NexEnabled or ply.NexEnabled == false then return false end
	local datatosend = RD.GetPosValue(pos)
	umsg.Start("RecievePosData",ply)
	umsg.Vector(datatosend.pos)
	umsg.Long(datatosend.radius)
	umsg.String(type(datatosend.value))
	if type(datatosend.value) == "table" then
		
	elseif type(datatosend.value) == "bool" or type(datatosend.value) == "boolean" then --Not sure which/I remember an error where true was one and false was the other...meh. Better Safe than sorry.
		umsg.Bool(datatosend.value)
	elseif type(datatosend.value) == "string" then
		umsg.String(datatosend.value)
	elseif type(datatosend.value) == "number" then
		umsg.Float(datatosend.value)
	elseif type(datatosend.value) == "vector" then
		umsg.Vector(datatosend.value)
	elseif type(datatosend.value) == "angle" then
		umsg.Angle(datatosend.value)
	elseif type(datatosend.value) == "entity" then
		umsg.Entity(datatosend.value)
	end
	umsg.End()
	return true
end ]]

function RD.SendPosDataToClient(ply,pos) --mm...debating weather it should send value or not...perhaps ifit's not a table...and priority shouldn't be needed clientside...so...
	print("Sending")
	datastream.StreamToClients(ply,"RecievePosData",RD.GetPosValue(pos))
end

function RD.FindRandGroundPos(radius,priority,value)
	print("I can has call? pl0x")
	local pos = nil
	if not radius or radius < 0 then radius = 0 end
	local tries = 50 --I know it sounds extreme, but when you want a pos, you WANT a pos.
	local found = 0
	local returntbl = {}
	for  i=1,tries do
		print("Trying...")
		pos = VectorRand()*16384
		if (util.IsInWorld( pos ) == true) then
			for k, v in pairs(positions) do
				print("Checking")
				if v and v.pos and (v.pos == pos or (v.pos:Distance(pos) < v.radius+radius and v.priority > priority)) then
					found = -1
				end
			end
			if found ~= -1 then
				local trace = {}
				trace.start = pos
				trace.endpos = pos + Vector(0,0,-16384) --To the bottom of the map + some. Hopefully.
				trace.filter = {}
				local tr = util.TraceLine( trace )
				if tr.Hit and tr.HitWorld and not tr.HitSky then
					local RD = CAF.GetAddon("Nex Mining")
					returntbl = RD.SetPositionValue(tr.HitPos,radius,priority,value)
					found = 1
					break
				end
			else
				found = 0
			end
			if (found == 0) then print("And we try to find a random pos again...") end
		end
	end
	print("Returning")
	return returntbl
end

local function ToggleNexMiningEnable(ply,cmds,args)
	if not ply.NexEnabled then ply.NexEnabled = false end
	ply.NexEnabled = !ply.NexEnabled
end
concommand.Add("__DO_NOT_TOUCH_OR_YOU_WILL_ERROR__",ToggleNexMiningEnable)

local function PLayInitSpawHook(ply)
	local Nex = CAF.GetAddon("Nex Mining")
	for k,v in pairs(Nex.GetAllPositions()) do
		Nex.SendPosDataToClient(ply,tostring(v.pos))
		print("Init sending")
	end
end
hook.Add("PlayerInitialSpawn","NexPlayerInitSpawnHook",PlayerInitSpawnHook)