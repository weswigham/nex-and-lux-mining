include('shared.lua')

//models:
//models/Slyfo/rover_drillshaft.mdl
//models/Slyfo/rover_drillbit.mdl
//models/Slyfo/rover_drillbase.mdl


function ENT:Draw()
    self.Entity:DrawModel()
    
    if not self.Shaft then
        self.Shaft = ClientsideModel( "models/Slyfo/rover_drillshaft.mdl", RENDERGROUP_OPAQUE )
    end
    if not self.Drill then
        self.Drill = ClientsideModel( "models/Slyfo/rover_drillbit.mdl", RENDERGROUP_OPAQUE )
    end

    local rot = self:GetAngles()
    rot:RotateAroundAxis(self:GetAngles():Up(),CurTime()*20)
    
    self.Shaft:SetAngles(rot)
    self.Drill:SetAngles(rot)
    
    if self:GetNWInt("Drilling") > 256 then
        self.Shaft:SetModelScale(Vector(1,1,self:GetNWInt("Drilling")/128))
    else
        self.Shaft:SetModelScale(Vector(1,1,1))
    end
    
    local addShaft = Vector(-40,0,125-(self:GetNWInt("Drilling") or 0)) --I can't believe I need to remake the object or it fux up... grrrrr
    local addDrill = Vector(-40,0,0-(self:GetNWInt("Drilling") or 0))

    addShaft:Rotate(self:GetAngles())
    addDrill:Rotate(self:GetAngles())

    self.Shaft:SetPos(self:GetPos()+addShaft)
    self.Drill:SetPos(self:GetPos()+addDrill)
    
end

function ENT:OnRemove()

    if self.Shaft and self.Shaft:IsValid() then
        self.Shaft:Remove()
    end
    if self.Drill and self.Drill:IsValid() then
        self.Drill:Remove()
    end

end




