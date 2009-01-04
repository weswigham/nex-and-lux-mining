TOOL.Category			= "Nex Mining"
TOOL.Name				= "Nex Mining Devices"

TOOL.DeviceName			= "Nex Mining Device"
TOOL.DeviceNamePlural	= "Nex Mining Devices"
TOOL.ClassName			= "nex_mining"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "mine"
TOOL.CCVar_sub_type		= "normal"
TOOL.CCVar_model		= "models/props_trainstation/TrackLight01.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "nex_mining"
TOOL.Limit				= 40

RD2ToolSetup.SetLang("Nex Mining Devices","Create Nex Mining Devices.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {
}

function TOOL.ExtraCCVarsCP( tool, panel )
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}
	return Extra_Data
end

local function resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "liquid nex", math.Round(vol / 2))
	return mass, maxhealth
end

TOOL.Devices = {
	resource_storage = {
		Name	= "Nex Resource Storage",
		type	= "resource_storage",
		class	= "nex_resource_storage",
		func	= resource_storage_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/ce_ls3additional/resource_cache/resource_cache_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "CE Small Storage",
				model	= "models/ce_miningmodels/miningstorage/storage_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_resource_storage",
	},
}

