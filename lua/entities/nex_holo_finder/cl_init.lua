include('shared.lua')

//models:
//models/Combine_Helicopter/helicopter_bomb01.mdl
//models/Slyfo/util_tracker.mdl

local MCol = Color(40,40,200,100)
local DebugMat = "models/debug/debugwhite"
local SmallScale = Vector(0.1,0.1,0.1)

function ENT:Initialize()
    self.PosSphere = {}
    self.Radius = 4000
end


function ENT:Draw()
	   self.Entity:DrawModel()
	   
	   if self:GetNWInt("DrawHolo") == 1 then
		   if not self.MainSphere then
			   self.MainSphere = ClientsideModel( "models/Combine_Helicopter/helicopter_bomb01.mdl", RENDERGROUP_BOTH )
			   self.MainSphere:SetMaterial(DebugMat)
			   self.MainSphere:SetColor(MCol.r,MCol.g,MCol.b,MCol.a)
		   end
		   self.MainSphere:SetNoDraw(false)
        
		   local rot = self:GetAngles()
		   rot:RotateAroundAxis(self:GetAngles():Up(),CurTime()*20)
	   
		   self.MainSphere:SetAngles(rot)
	   
		   local addSpheres = Vector(0,0,20) --I can't believe I need to remake the object or it fux up... grrrrr

		   addSpheres:Rotate(self:GetAngles())

		   self.MainSphere:SetPos(self:GetPos()+addSpheres)
        
        local postbl = CAF.GetAddon("Nex Mining").GetAllPositions()
        for k,v in pairs(postbl) do
            if v.pos:Distance(self.MainSphere:GetPos()) > self.Radius then
                postbl[k] = nil --Out of range
                if self.PosSphere[k] then self.PosSphere[k]:Remove()  self.PosSphere[k] = nil end
            end
        end
        for k,v in pairs(postbl) do
            if v.pos:Distance(self.MainSphere:GetPos()) < self.Radius then --within radius
            if not self.PosSphere then self.PosSphere = {} end
            if not self.PosSphere[k] then
                self.PosSphere[k] = ClientsideModel( "models/Combine_Helicopter/helicopter_bomb01.mdl", RENDERGROUP_BOTH )
                self.PosSphere[k]:SetMaterial(DebugMat)
                self.PosSphere[k]:SetColor(200,200,10,230)
                self.PosSphere[k]:SetModelScale(SmallScale)
            end
            self.PosSphere[k]:SetNoDraw(false)
            
            local smallpos = ((self.MainSphere:GetPos()-v.pos):Normalize()*(self.MainSphere:GetPos():Distance(v.pos)/400))

            self.PosSphere[k]:SetPos(self.MainSphere:GetPos()+smallpos)

            if v.pos:Distance(self.MainSphere:GetPos()) <= v.radius then
                self.PosSphere[k]:SetColor(200,50,10,230)
            else
                self.PosSphere[k]:SetColor(200,200,10,230)
            end
            elseif self.PosSphere and self.PosSphere[k] then
                self.PosSphere[k]:SetColor(0,0,0,0)
            end
        end
	   else
		   if self.MainSphere then
			   self.MainSphere:SetColor(0,0,0,0)
		   end
        for k,v in pairs(self.PosSphere) do
            v:SetColor(0,0,0,0)
        end
	   end
	   
end

function ENT:OnRemove()

	   if self.MainSphere and self.MainSphere:IsValid() then
		   self.MainSphere:Remove()
	   end
    for k,v in pairs(self.PosSphere) do
        v:Remove()
    end

end






