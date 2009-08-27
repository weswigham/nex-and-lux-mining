AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')

function ENT:Initialize()

	if not self.type then self.type = "nex" end
	if not self.damage_low then self.damage_low = 1 end
	if not self.damage_high then self.damage_high = 6 end
	if not self.maxs then self.maxs = Vector(0,0,0) end
	if not self.mins then self.mins = Vector(0,0,0) end
	self:SetModel("models/props_combine/combine_mine01.mdl")
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableCollisions(false)
		phys:EnableGravity(false)
	end
	self:SetNoDraw(true)
end 

function ENT:Think()
	local efct = EffectData()
	efct:SetOrigin(self.mins)
	efct:SetStart(self.maxs)
	efct:SetEntity(self)
	util.Effect(self.type.."_cloud",efct)
	local entstodamage = ents.FindInBox(self:LocalToWorld(self.mins),self:LocalToWorld(self.maxs))
	for k,v in pairs(entstodamage) do
		if self.type == "nex" then
			if v:GetClass() == "lux_resource_storage" and (v.damaged == 1 or v.vent) then
				v:TakeDamage(math.random((self.damage_low or 0)*10,(self.damage_high or 1)*11),self:GetOwner(),self)
			else
				v:TakeDamage(math.random(self.damage_low,self.damage_high),self:GetOwner(),self)
			end
		else
			if v:GetClass() == "nex_resource_storage" and (v.damaged == 1 or v.vent) then
				v:TakeDamage(math.random((self.damage_high or -1)*11,(self.damage_low or 0)*10),self:GetOwner(),self)
			else
				v:SetHealth(math.Clamp(v:Health()-math.random(self.damage_low,self.damage_high),0,v:GetMaxHealth()))
			end
		end
	end

	local dosomething,ent = self:CheckBounds()
	if dosomething then
		local efct = EffectData()
		efct:SetOrigin(self:GetPos())
		efct:SetScale(5)
		efct:SetRadius(math.abs(self.mins:Dot(self.maxs)))
		efct:SetEntity(self)
		util.Effect("Explosion",efct)
		if ent:GetParent() and ent:GetParent():IsValid() then
			ent:GetParent():Remove()
		end
		if self:GetParent() and self:GetParent():IsValid() then
			self:GetParent():Remove()
		end
	end
	self:NextThink(CurTime()+0.8)
end 

function ENT:SetCloudBounds(mins,maxs)
	self.maxs = maxs
	self.mins = mins
end 

function ENT:SetDamageAmts(minz,maxz)
	self.damage_low = minz
	self.damage_high = maxz
end 

function ENT:SetType(typez)
	self.type = typez
end 

function ENT:CheckBounds()
	for k,v in pairs(ents.FindByClass("gas_cloud")) do
		if v != self then
			if (self.type == "nex" and v.type == "lux") or (self.type == "lux" and v.type == "nex") then
				if self:CompareBounds(v) == true then
					return true,v
				end
			end
		end
	end
	return false
end 

function ENT:CompareBounds(ent) --Something is STILL screwed up.
	local offset = self:LocalToWorld(self.mins)
	local maxvals = self:LocalToWorld(self.maxs)-offset
	for k,v in pairs(ent:GetAllWorldCorners()) do
		local pos = v-offset
		if pos.x > 0 and pos.y > 0 and pos.z > 0 and pos.x < maxvals.x and pos.y < maxvals.y and pos.z < maxvals.z then 
			return true 
		end
	end
	return false
end

function ENT:GetAllWorldCorners()
	local selfcorners = {}
	table.insert(selfcorners, self:LocalToWorld(self.maxs))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.maxs.x,self.maxs.y,self.mins.z)))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.maxs.x,self.mins.y,self.mins.z)))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.mins.x,self.maxs.y,self.mins.z)))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.mins.x,self.mins.y,self.maxs.z)))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.mins.x,self.maxs.y,self.maxs.z)))
	table.insert(selfcorners, self:LocalToWorld(Vector(self.maxs.x,self.mins.y,self.maxs.z)))
	table.insert(selfcorners, self:LocalToWorld(self.mins))
	return selfcorners
end 