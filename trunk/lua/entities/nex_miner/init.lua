AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local BeamLength = 512
local Energy_Increment = 200
local Maxlength = 1024
--local Refire_Rate = 0.6

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.Minelevel = Minelevel
	self.DrillDepth = BeamLength
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Depth" })
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
	if (iname == "Depth") then
		if value > Maxlength then
			self.DrillDepth = Maxlength
			return
		end
		self.DrillDepth = value
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
	self.Entity:StopSound( "Airboat_engine_idle" )
end

function ENT:Mine()
	local ent = self.Entity
	local RD = CAF.GetAddon("Resource Distribution")
	self.energy =  RD.GetResourceAmount(self, "energy")
	local einc = math.Round(Energy_Increment * (self.DrillDepth / 512))
	if (self.energy >= einc) then
		local Pos = ent:GetPos()
		local Ang = ent:GetAngles()
		local trace = {}

    local addDrill = Vector(-40,0,0)
    addDrill:Rotate(self:GetAngles())
    trace.start = Pos+addDrill
    trace.endpos = Pos+addDrill+(Ang:Up()*-1*self.DrillDepth)
    
		trace.filter = { ent }
		local tr = util.TraceLine( trace )

		local data = CAF.GetAddon("Nex Mining").GetPosValue(tr.HitPos)
		
		if data and data.value then
			if tr.HitPos:Distance(tr.StartPos)+data.value.Depth <= self.DrillDepth then --we've struck nex!
			
				RD.ConsumeResource(self, "energy", einc)
				local ammountToTake = math.Clamp((100/data.value.Depth)*math.random(500,750),0,data.value.Ammount)
				RD.SupplyResource(self, data.value.Type, math.floor(ammountToTake))
				CAF.GetAddon("Nex Mining").SetPositionValue(data.pos,data.radius,data.priority,{Type=data.value.Type,Depth=data.Value.Depth,Ammount=(data.value.Ammount-math.floor(ammountToTake))})
				if (data.value.Ammount-math.floor(ammountToTake)) <= 0 then --remove it
					CAF.GetAddon("Nex Mining").ClearPosition(data.pos)
				end
			end
		end
		
		local effectdata = EffectData()
		effectdata:SetEntity( ent )
		effectdata:SetOrigin( Pos+addDrill )
		effectdata:SetStart( tr.HitPos )
		effectdata:SetAngle( Ang )
		util.Effect( "mining_beam", effectdata, true, true )
		--Msg('Thought')
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			self:Mine()
	end
	self.Entity:NextThink( CurTime() + 1 )
	return true
end





