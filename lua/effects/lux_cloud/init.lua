
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 3
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin() --Mins
 	self.vEnd = data:GetStart() --Maxs
	self.Ent = data:GetEntity()
	
	self.emitter = ParticleEmitter( self.vOffset )
	local scount = math.random(10,30)
		for i = 1, scount do
		
			local particle = self.emitter:Add( "lux/lux_particle1", self.Ent:GetPos()+Vector(math.random(self.vOffset.x,self.vEnd.x),math.random(self.vOffset.y,self.vEnd.y),math.random(self.vOffset.z,self.vEnd.z)) )
			if (particle) then
				particle:SetVelocity( Vector(0,0,1) * math.Rand(1, 10) )
				--particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 20, 205 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 40 )
				particle:SetEndSize( 70 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( 255 , 255 , 255 )
			end
		end
	self.emitter:Finish()

 	self.Entity:SetPos( self.vOffset )  
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 

end  