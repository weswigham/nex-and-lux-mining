AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local ConsumptionRate = 500


function ENT:Destruct()

end


function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self.Entity, {"On" })
	else
		self.Inputs = {{Name="On"},{Name="Depth"}}
	end
end

function ENT:TurnOn()
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
end

function ENT:TurnOff()
	if (self.Active == 1) then
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
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self:SetHealth( self:GetMaxHealth())
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Nex Mining") then
		CAF.GetAddon("Nex Mining").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:UpdateClients()
    local RD = CAF.GetAddon("Resource Distribution")
    self.energy =  RD.GetResourceAmount(self, "energy")
    if self.energy >= ConsumptionRate then
        self:SetNWInt("DrawHolo",1)
        RD.ConsumeResource(self,"energy",ConsumptionRate)
    else
        self:TurnOff()
    end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
    self:UpdateClients()
 else
    self:SetNWInt("DrawHolo",0)
	end
	self.Entity:NextThink( CurTime() + 1 )
	return true
end











