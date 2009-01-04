<<<<<<< .mine
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self.Entity, {"On" })
	end
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:SetActive( value )

end

function ENT:TriggerInput(iname, value)

end

function ENT:Damage()

end

function ENT:Repair()

end

function ENT:Destruct()

end

function ENT:OnRemove()

end


function ENT:Think()
	self.BaseClass.Think(self)

	self.Entity:NextThink( CurTime() + 1 )
	return true
end
=======
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.nex = 0
	self.damaged = 0
	self.vent = false
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Vent" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "liquid nex", "Max liquid nex" })
	else
		self.Inputs = {{Name="Vent"}}
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Vent") then
		if (value != 1) then
			self.vent = false
		else
			self.vent = true
		end
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.Entity:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:Leak()
	local RD = CAF.GetAddon("Resource Distribution")
	local nex = RD.GetResourceAmount(self, "liquid nex")
	if nex > 0 then
		if (math.random(1, 10) < 9) then
			local dec = math.random(200, 2000)
			RD.ConsumeResource(self, "liquid nex", dec)
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ((self.damaged == 1 or self.vent)) then
		self:Leak()
	end
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local RD = CAF.GetAddon("Resource Distribution")
	local nex = RD.GetResourceAmount(self, "liquid nex")
	local maxnex = RD.GetNetworkCapacity(self, "liquid nex")
	Wire_TriggerOutput(self.Entity, "liquid nex", nex)
	Wire_TriggerOutput(self.Entity, "Max liquid nex", maxnex)
end
>>>>>>> .r6
