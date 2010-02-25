AddCSLuaFile("shared.lua")

SWEP.Author			= "Levybreak"
SWEP.Contact			= "fp"
SWEP.Purpose			= "To find Nex and Lux caches visually."
SWEP.Instructions		= "Just equip it and look around. It will drain suit energy, though."
 
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
 
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
 
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"
 
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

if SERVER then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then
	SWEP.PrintName        = "Visual NLC Arrary"			
	SWEP.Slot		= 2
	SWEP.SlotPos		= 3
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= false
end

SWEP.SensorRange = 3000
SWEP.EnergyUseage = 0.1
 
/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()

end

local DebugMat = "models/debug/debugwhite"
local Scale = Vector(1,1,1)


--PostDrawOpaqueRenderables
 
/*---------------------------------------------------------
  Think
---------------------------------------------------------*/
function SWEP:Think()
	if SERVER then
		local ply = self:GetOwner()
		if ply:GetActiveWeapon():GetClass() == self:GetClass() then
			if ply.suit.energy >= self.EnergyUseage then
				ply.suit.energy = ply.suit.energy - self.EnergyUseage
			else
				self:CallOnClient("ClearView","")
				ply:DropWeapon(ply:GetActiveWeapon())
				ply:PrintMessage(HUD_PRINTTALK, "You have dropped your Visual NLC Array as you are out of suit energy!")
			end
		end
		self:NextThink(CurTime()+1)
	end
end

local function OverlayDraw()
	DrawMaterialOverlay( "models/props_combine/stasisshield_sheet", 0.025 )
	DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.1 )
end

function SWEP:Initialize()
	if CLIENT then
		--self:StartView()
		return true
	end
	if SERVER then
		--local ply = self:GetOwner()
		--return ply.suit.energy >= self.EnergyUseage 
		return true
	end
end

function SWEP:Deploy()
	if CLIENT then
		self:StartView()
		return true
	end
	if SERVER then
		local ply = self:GetOwner()
		return ply.suit.energy >= self.EnergyUseage 
	end
end

function SWEP:ClearView()
	if CLIENT then
		hook.Remove( "RenderScreenspaceEffects", "VisualNexLuxSphereDraw")
		hook.Remove( "RenderScreenspaceEffects", "VisualNexLuxOverlayDraw")
		LocalPlayer().LSHudOn = false
	end
end

function SWEP:StartView()
	if CLIENT then
		local function DrawAllTheSpheres()
			local postbl = CAF.GetAddon("Nex Mining").GetAllPositions()
			for k,v in pairs(postbl) do
				if v.pos:Distance(self:GetOwner():GetShootPos()) > self.SensorRange then
					postbl[k] = nil --Out of range
				end
			end
			
			self.SphereModel = self.SphereModel or ClientsideModel( "models/Combine_Helicopter/helicopter_bomb01.mdl", RENDERGROUP_BOTH )
			self.SphereModel:SetMaterial(DebugMat)
			self.SphereModel:SetNoDraw(true)
			for k,v in pairs(postbl) do
				cam.Start3D( EyePos(), EyeAngles() )
					render.SuppressEngineLighting( true )
					if v.value.Type == "liquid lux" then
						render.SetColorModulation( 150/255,150/255,20/255 )
					elseif v.value.Type == "liquid nex" then
						render.SetColorModulation( 150/255, 0 ,200/255 )
					else
						render.SetColorModulation( 1, 1, 1 )
					end
					render.SetBlend( math.Clamp((math.Clamp(200-math.floor(v.value.Depth*2),0,200)/255) - (v.pos:Distance(EyePos())/self.SensorRange),0,1))
					SetMaterialOverride( DebugMat )
					
					self.SphereModel:SetPos(v.pos)
					self.SphereModel:SetModelScale(Scale*(v.radius/15))
					self.SphereModel:DrawModel()
	 
					render.SuppressEngineLighting( false )
					render.SetColorModulation( 1, 1, 1 )
					render.SetBlend( 1 )
					SetMaterialOverride( 0 )
				cam.End3D()
			end
		end
		hook.Add( "RenderScreenspaceEffects", "VisualNexLuxSphereDraw", DrawAllTheSpheres )
		hook.Add( "RenderScreenspaceEffects", "VisualNexLuxOverlayDraw", OverlayDraw )
		LocalPlayer().LSHudOn = true
	end
end

function SWEP:Holster()
	if CLIENT then
		self:ClearView()
	end
	return true
end
 
/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
 
end
 
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
 
end