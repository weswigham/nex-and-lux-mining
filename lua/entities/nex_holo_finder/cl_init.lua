include('shared.lua')

//models:
//models/Combine_Helicopter/helicopter_bomb01.mdl
//models/Slyfo/util_tracker.mdl

local MCol = Color(40,40,200,100)
local DebugMat = "models/debug/debugwhite"


function ENT:Draw()
    self.Entity:DrawModel()
    
    if self:GetNWInt("DrawHolo") == 1 then
        if not self.MainSphere then
            self.MainSphere = ClientsideModel( "models/Combine_Helicopter/helicopter_bomb01.mdl", RENDERGROUP_BOTH )
            self.MainSphere:SetMaterial(DebugMat)
            self.MainSphere:SetColor(MCol.r,MCol.g,MCol.b,MCol.a) --setting the color of a clientside model seems to make it not draw...
        else
            self.MainSphere:SetNoDraw(false)
        end
        local rot = self:GetAngles()
        rot:RotateAroundAxis(self:GetAngles():Up(),CurTime()*20)
    
        self.MainSphere:SetAngles(rot)
    
        local addSpheres = Vector(0,0,20) --I can't believe I need to remake the object or it fux up... grrrrr

        addSpheres:Rotate(self:GetAngles())

        self.MainSphere:SetPos(self:GetPos()+addSpheres)
    else
        if self.MainSphere then
            self.MainSphere:SetNoDraw(true)
        end
    end
    
end

function ENT:OnRemove()

    if self.MainSphere and self.MainSphere:IsValid() then
        self.MainSphere:Remove()
    end

end





