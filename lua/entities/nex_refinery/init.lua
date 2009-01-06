AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local ConversionRatio = 0.4 --Ratio of intake to outtake. 0.4 will intake 40 and output 40% of 40.
local ConversionsPerThink = 5 --Self Explanitory.
local EnergyPerConversion = 20

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.ConversionSpeed = ConversionsPerThink
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self.Entity, {"On" })
	else
		self.Inputs = {{Name="On"}}
	end
end

function ENT:TurnOn()
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Entity:StopSound( "Airboat_engine_idle" )
		self.Entity:EmitSound( "Airboat_engine_stop" )
		self.Entity:StopSound( "apc_engine_start" )
		self.Active = 0
	end
end

function ENT:SetActive( value )
	if not (value == nil) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
	if not self.gascloud or not self.gascloud:IsValid() then
		local mins = self:OBBMins()*3
		local maxs = self:OBBMaxs()*3
		local ent = ents.Create("gas_cloud")
		ent:SetPos(self:GetPos())
		ent:SetCloudBounds(mins,maxs)
		ent:SetDamageAmts(1,6)
		ent:SetType("nex")
		ent.type = "nex"
		ent:SetParent(self)
		ent:Spawn()
		self.gascloud = ent
		ent.dependant = self
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self:SetHealth( self:GetMaxHealth( ))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "Airboat_engine_idle" )
end

function ENT:Refine()
	local RD = CAF.GetAddon("Resource Distribution")
	self.energy =  RD.GetResourceAmount(self, "energy")
	self.lnex = RD.GetResourceAmount(self, "liquid nex")
	local energyRequired = self.ConversionSpeed*EnergyPerConversion+math.random(-5,5)
	if self.lnex >= self.ConversionSpeed*10 and (self.energy >= energyRequired) then
		RD.ConsumeResource(self, "liquid nex", self.ConversionSpeed*10)
		RD.SupplyResource(self, "arma nex", self.ConversionSpeed*10*ConversionRatio)
		RD.ConsumeResource(self, "energy", energyRequired)
	elseif self.lnex > 0 and self.energy > self.lnex*EnergyPerConversion+math.random(-5,5) then
		RD.ConsumeResource(self, "liquid nex", self.lnex)
		RD.SupplyResource(self, "arma nex", self.lnex*ConversionRatio)
		RD.ConsumeResource(self, "energy", self.lnex*EnergyPerConversion+math.random(-5,5))
	else
		self:TurnOff()
	end
end

function ENT:SetConversionSpeed(num)
	self.ConversionSpeed = num
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			self:Refine()
	end
	if self.damaged == 1 then
		self:DamagedThink()
	end
	self.Entity:NextThink( CurTime() + 1 )
	return true
end

function ENT:DamagedThink()
	if not self.gascloud or not self.gascloud:IsValid() then
		local mins = self:OBBMins()*3
		local maxs = self:OBBMaxs()*3
		local ent = ents.Create("gas_cloud")
		ent:SetPos(self:GetPos())
		ent:SetCloudBounds(mins,maxs)
		ent:SetDamageAmts(1,6)
		ent:SetType("nex")
		ent.type = "nex"
		ent:SetParent(self)
		ent:Spawn()
		self.gascloud = ent
		ent.dependant = self
	end
	local RD = CAF.GetAddon("Resource Distribution")
	self.lnex = RD.GetResourceAmount(self, "liquid nex")
	RD.ConsumeResource(self, "liquid nex", math.random(40,500))
end
