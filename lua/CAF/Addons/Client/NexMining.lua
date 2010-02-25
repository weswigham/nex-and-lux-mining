local RD = {}

require("datastream")

local status = false

--The Class
/**
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	RunConsoleCommand("__DO_NOT_TOUCH_OR_YOU_WILL_ERROR__")
	status = true
	return true , "Nex Mining Activated"
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	RunConsoleCommand("__DO_NOT_TOUCH_OR_YOU_WILL_ERROR__")
	status = false
	return true , "Nex Mining Deactivated"
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

function RD.GetMenu(menutype, menuname)//Name is nil for main menu, String for others
	local data = {}
	if not menutype then
		--Create Help Menu
		data["Help"] = {}
		tmp = data["Help"];
		tmp["Nex Mining Thread"] = {}
		tmp["Nex Mining Thread"].localurl = "test/test.html";
		tmp["Nex Mining Thread"].interneturl = "http://www.facepunch.com/";
		
	end
	return data
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

function RD.GetDescription()
	return {
				"Nex Mining",
				"A Space Mining Addon",
				"By:",
				"Levybreak --Coder", 
				"SLYFo --Modeler",
				"and Paradukes --Coder"
			}
end

CAF.RegisterAddon("Nex Mining", RD, "2")


local positions = {}
--[[
local function RecievePosTableData(um) --Simplifying to datastream module for speed "powered by JSon"
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
usermessage.Hook("RecievePosData",RecievePosTableData)]]

local function RecievePosTableData(hand,id,enc,data)
	print("Recieving")
	positions[tostring(data.pos)] = data
end
datastream.Hook("RecievePosData",RecievePosTableData)

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
		if v.pos:Distance(pos) <= dist and v.value == value then 
			dist = v.pos:Distance(pos) 
			out = v
		end
	end
	return v
end

function RD.GetAllPositions()
	return table.Copy(positions)
end

function RD.GetAllPositionsString()
	local sanitizd = table.Sanitise(positions)
	local strg = util.TableToKeyValues(sanitizd)
	return strg
end 
