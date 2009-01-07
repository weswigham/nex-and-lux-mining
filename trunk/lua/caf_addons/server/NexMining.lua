--[[ Serverside Custom Addon file Base ]]--

local RD = {}

/*
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	if status then return false, "Already Active!" end
	if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then return false, "Resource Distribution is Required and needs to be Active!" end
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
	return "Not Implemented Yet"
end

/**
	You can send all the files from here that you want to add to send to the client
*/
function RD.AddResourcesToSend()
	
end

CAF.RegisterAddon("Nex Mining", RD, "2") 

local positions = {}
function RD.SetPositionValue(pos,radius,priority,value)
		positions[tostring(pos)] = {}
		positions[tostring(pos)].pos = pos
		positions[tostring(pos)].radius = radius
		positions[tostring(pos)].priority = priority
		positions[tostring(pos)].value = value
end

function RD.ClearPosition(pos)
	if positions[tostring(pos)] then positions[tostring(pos)] = nil end
end

function RD.GetPosValue(pos)
	local returnval = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= v.radius then
			if returnval then 
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
	local dist = 999999999999999999
	local out = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= dist then 
			dist = v.pos:Distance(pos) 
			out = v
		end
	end
	return v
end

function RD.GetAllPositions()
	return positions
end

function RD.GetAllPositionsString()
	local sanitizd = table.Sanitise(positions)
	local strg = util.TableToKeyValues(sanitizd)
	return strg
end 
