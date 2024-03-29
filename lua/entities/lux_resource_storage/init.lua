AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Vent" })
	else
		self.Inputs = {{Name="Vent"}}
	end
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:SetActive( value )

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
	if (self.damaged == 0) then 
		self.damaged = 1 
		local RD = CAF.GetAddon("Resource Distribution")
		local lux = RD.GetResourceAmount(self, "liquid lux")
		if self.arma and self.arma == true then lux = RD.GetResourceAmount(self, "arma lux") end
		if lux > 0 then
			if not self.gascloud or not self.gascloud:IsValid() then
				local mins = self:OBBMins()*3
				local maxs = self:OBBMaxs()*3
				local ent = ents.Create("gas_cloud")
				ent:SetPos(self:GetPos())
				ent:SetCloudBounds(mins,maxs)
				ent:SetDamageAmts(-6,-1)
				ent:SetType("lux")
				ent:SetParent(self)
				ent:Spawn()
				self.gascloud = ent
				ent.dependant = self
			end
		end
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.Entity:SetColor(255, 255, 255, 255)
	self.damaged = 0
	if self.gascloud and self.gascloud:IsValid() then self.gascloud:Remove() end
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	if self.gascloud and self.gascloud:IsValid() then self.gascloud:Remove() end
end

function ENT:Leak()
	local RD = CAF.GetAddon("Resource Distribution")
	local nex = RD.GetResourceAmount(self, "liquid lux")
	if self.arma and self.arma == true then nex = RD.GetResourceAmount(self, "arma lux") end
	if nex > 0 then
			
			if (math.random(1, 10) < 9) then
				local dec = math.random(1200, 9000)
				if self.arma and self.arma == true then
					RD.ConsumeResource(self, "arma lux", dec)
				else
					RD.ConsumeResource(self, "liquid lux", dec)
				end
				if not self.gascloud or not self.gascloud:IsValid() then
					local mins = self:OBBMins()*3
					local maxs = self:OBBMaxs()*3
					local ent = ents.Create("gas_cloud")
					ent:SetPos(self:GetPos())
					ent:SetCloudBounds(mins,maxs)
					ent:SetDamageAmts(-6,-1)
					ent:SetType("lux")
					ent.type = "lux"
					ent:SetParent(self)
					ent:Spawn()
					self.gascloud = ent
					ent.dependant = self
				end
			end
	end
end


function ENT:Think()
	self.BaseClass.Think(self)
	if ((self.damaged == 1 or self.vent)) then
		self:Leak()
	elseif self.gascloud and self.gascloud:IsValid() then
		self.gascloud:Remove()
	end
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local RD = CAF.GetAddon("Resource Distribution")
	if self.arma and self.arma == true then
	local nex = RD.GetResourceAmount(self, "arma lux")
	local maxnex = RD.GetNetworkCapacity(self, "arma lux")
	Wire_TriggerOutput(self.Entity, "arma lux", nex)
	Wire_TriggerOutput(self.Entity, "Max arma lux", maxnex)
	else
	local nex = RD.GetResourceAmount(self, "liquid lux")
	local maxnex = RD.GetNetworkCapacity(self, "liquid lux")
	Wire_TriggerOutput(self.Entity, "liquid lux", nex)
	Wire_TriggerOutput(self.Entity, "Max liquid lux", maxnex)
	end
end 