TOOL.Category			= "Nex Mining"
TOOL.Name				= "Nex Mining Devices"

TOOL.DeviceName			= "Nex Mining Device"
TOOL.DeviceNamePlural	= "Nex Mining Devices"
TOOL.ClassName			= "nex_mining"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "mine"
TOOL.CCVar_sub_type		= "normal"
TOOL.CCVar_model		= "models/ce_ls3additional/resource_cache/resource_cache_large.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "nex_mining"
TOOL.Limit				= 40

CAFToolSetup.SetLang("Nex Mining Devices","Create Nex Mining Devices.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {
}

function TOOL.ExtraCCVarsCP( tool, panel )
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}
	return Extra_Data
end

local function nex_resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 400
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "liquid nex", math.Round(vol / 2))
	return mass, maxhealth
end

local function lux_resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 400
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "liquid lux", math.Round(vol / 2))
	return mass, maxhealth
end

local function arma_nex_resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 400
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "arma nex", math.Round(vol / 5))
	ent.arma = true
	return mass, maxhealth
end

local function arma_lux_resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 400
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "arma lux", math.Round(vol / 5))
	ent.arma = true
	return mass, maxhealth
end

local function generic_nonstorage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 400
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume()
	vol = math.Round(vol)
	ent.burnRate = math.Clamp(vol/5000,25,5000)
	return mass, maxhealth
end

TOOL.Devices = {
	nex_resource_storage = {
		Name	= "Nex Resource Storage",
		type	= "nex_resource_storage",
		class	= "nex_resource_storage",
		func	= nex_resource_storage_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/Slyfo/crate_resource_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "SLYFo Small Storage",
				model	= "models/Slyfo/crate_resource_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			SLYFo1 = {
				Name	= "SLYFo Small Barrel",
				model	= "models/Slyfo/barrel_unrefined.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_resource_storage",
	},
	lux_resource_storage = {
		Name	= "Lux Resource Storage",
		type	= "lux_resource_storage",
		class	= "lux_resource_storage",
		func	= lux_resource_storage_func,
		devices = {
			normalz = {
				Name	= "Default",
				model	= "models/Slyfo/crate_resource_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			SLYFo1 = {
				Name	= "SLYFo Small Barrel",
				model	= "models/Slyfo/barrel_orange.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "lux_resource_storage",
	},
	arma_nex_resource_storage = {
		Name	= "Arma Nex Resource Storage",
		type	= "arma_nex_resource_storage",
		class	= "nex_resource_storage",
		func	= arma_nex_resource_storage_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/Slyfo/crate_resource_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "SLYFo Small Storage",
				model	= "models/Slyfo/crate_resource_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			SLYFo1 = {
				Name	= "SLYFo Small Barrel",
				model	= "models/Slyfo/barrel_refined.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_resource_storage",
	},
	arma_lux_resource_storage = {
		Name	= "Arma Lux Resource Storage",
		type	= "arma_lux_resource_storage",
		class	= "lux_resource_storage",
		func	= arma_lux_resource_storage_func,
		devices = {
			normalz = {
				Name	= "Default",
				model	= "models/Slyfo/crate_resource_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			SLYFo1 = {
				Name	= "SLYFo Small Barrel",
				model	= "models/Slyfo/barrel_orange.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "lux_resource_storage",
	},
	nex_refinery = {
		Name	= "Nex Refinery",
		type	= "nex_refinery",
		class	= "nex_refinery",
		func	= generic_nonstorage_func,
		devices = {
			large = {
				Name	= "Large SLYFo Refinery",
				model	= "models/Slyfo/refinery_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			normal = {
				Name	= "Medium SLYFo Refinery",
				model	= "models/Slyfo/refinery_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_refinery",
	},
	nex_incinerator = {
		Name	= "Nex Incinerator",
		type	= "nex_incinerator",
		class	= "nex_incinerator",
		func	= generic_nonstorage_func,
		devices = {
			large = {
				Name	= "Large SLYFo Refinery",
				model	= "models/Slyfo/refinery_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			normal = {
				Name	= "Medium SLYFo Refinery",
				model	= "models/Slyfo/refinery_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_incinerator",
	},
	nex_reactor = {
		Name	= "Nex-Lux Reactor",
		type	= "nex_reactor",
		class	= "nex_reactor",
		func	= generic_nonstorage_func,
		devices = {
			large = {
				Name	= "Medium SLYFo Crate Reactor",
				model	= "models/Slyfo/crate_reactor.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			normal = {
				Name	= "Medium SLYFo Refinery",
				model	= "models/Slyfo/refinery_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "nex_reactor",
	},
	nex_miner = {
		Name	= "Mining Drill",
		type	= "nex_miner",
		class	= "nex_miner",
		func	= generic_nonstorage_func,
		devices = {
    normal = {
     Name= "Rover Attachable Drill",
     model= "models/Slyfo/rover_drillbase.mdl",
     skin= 0,
     legacy= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
    },
		},
		['class'] = "nex_miner",
	},
    nex_holo_finder = {
        Name= "Holographic Nex Finder",
        type= "nex_holo_finder",
        class= "nex_holo_finder",
        func= generic_nonstorage_func,
        devices = {
            normal = {
                Name= "Point-Sphere Projection Module",
                model= "models/Slyfo/util_tracker.mdl",
                skin= 0,
                legacy= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
            },
        },
        ['class'] = "nex_holo_finder",
    },
}


