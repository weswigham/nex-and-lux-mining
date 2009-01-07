local RD = {}

local status = false

--The Class
/**
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	RunConsoleCommand("__DO_NOT_TOUCH_OR_YOU_WILL_ERROR__")
	return true , "No Implementation yet"
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	RunConsoleCommand("__DO_NOT_TOUCH_OR_YOU_WILL_ERROR__")
	return false , "No Implementation yet"
end

/**
	Get the required Addons for this Addon Class
*/
function RD.GetRequiredAddons()
	return {}
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
	Gets a menu from this Custom Addon Class
*/
function RD.GetMenu(menutype, menuname)//Name is nil for main menu, String for others
	local data = {}
	return data
end

/**
	Get the Custom String Status from this Addon Class
*/
function RD.GetCustomStatus()
	return "Not Implemented Yet"
end

CAF.RegisterAddon("Nex Mining", RD, "2")


local positions = {}
local function RecievePosTableData(um)
	local postbl = {}
	local postbl.pos = um:ReadVector()
	local postbl.radius = um:ReadLong()
	local typeofvalue = um:ReadString()
	if typeofvalue == "table" then
		postbl.value = {}
	elseif typeofvalue == "bool" or type(typeofvalue) == "boolean" then
		postbl.value = um:ReadBool()
	elseif typeofvalue == "string" then
		postbl.value = um:ReadString()
	elseif typeofvalue == "number" then
		postbl.value = um:ReadFloat()
	elseif typeofvalue == "vector" then
		postbl.value = um:ReadVector()
	elseif typeofvalue == "angle" then
		postbl.value = um:ReadAngle()
	elseif typeofvalue == "entity" then
		postbl.value = um:ReadEntity()
	end
	positions[postbl.pos] = postbl
end 
usermessage.Hook("RecievePosData",RecievePosTableData)

local function ClearPosition(um)
	local pos = um:ReadVector()
	if positions[tostring(pos)] then positions[tostring(pos)] = nil end
end
usermessage.Hook("RemovePosDataClientside",ClearPosition)

function RD.GetPosValue(pos)
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

function RD.GetNearestPosWithValue(pos,value)
	local dist = 999999999999999999
	local out = nil
	for k,v in pairs(positions) do
		if v.pos:Distance(pos) <= dist and v.value = value then 
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
