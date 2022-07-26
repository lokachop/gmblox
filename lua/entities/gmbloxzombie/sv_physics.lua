-- code by wireteam, edited by lokachop
-- https://github.com/wiremod/wire/blob/3221e99978b6dbab94afa5db6940988eec63c089/lua/entities/gmod_wire_expression2/core/entity.lua
function ApplyAngForce(ent, angForce)
	if angForce[1] == 0 and angForce[2] == 0 and angForce[3] == 0 then
		return
	end

	local phys = ent:GetPhysicsObject()

	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	-- apply pitch force
	if angForce[1] ~= 0 then
		local pitch = up * (angForce[1] * 0.5)
		phys:ApplyForceOffset( forward, pitch )
		phys:ApplyForceOffset( forward * -1, pitch * -1 )
	end

	-- apply yaw force
	if angForce[2] ~= 0 then
		local yaw = forward * (angForce[2] * 0.5)
		phys:ApplyForceOffset( left, yaw )
		phys:ApplyForceOffset( left * -1, yaw * -1 )
	end

	-- apply roll force
	if angForce[3] ~= 0 then
		local roll = left * (angForce[3] * 0.5)
		phys:ApplyForceOffset( up, roll )
		phys:ApplyForceOffset( up * -1, roll * -1 )
	end
end

local can_collide = {
	[COLLISION_GROUP_NONE] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_VEHICLE] = true,
	[COLLISION_GROUP_BREAKABLE_GLASS] = true,
	[COLLISION_GROUP_NPC] = true,
}

function ENT:Stand(filter)
	filter = filter or {}
	local noCheck = false
	if (self.StandItr or 0) > 6 then
		self.StandItr = 0
		noCheck = true
	end

	self.StandItr = (self.StandItr or 0) + 1

	if filter[1] ~= self then
		filter[1] = self
	end

	-- there's probably a much better way to do all of this but i horribly suck at vector math and this works
	-- if anyone knows a better method, please commit!

	local targetAng = self.targetAng
	local phys = self:GetPhysicsObject()


	local reachAng = self:WorldToLocalAngles(targetAng) * 200
	local angVel = self:GetLocalAngularVelocity() * 200

	local inertia = phys:GetInertia()
	local delta = (reachAng - angVel)
	local calc2 = Angle(delta.p * inertia.y, delta.y * inertia.z, delta.r * inertia.x)
	local fv = Vector(calc2.p, calc2.y, calc2.r)

	if IsValid(phys) then
		ApplyAngForce(self, fv * 2)
	end

	phys:AddAngleVelocity(-phys:GetAngleVelocity() / 2)

	-- now we need to actually stand
	local suspLen = 36.5
	local suspDamp = 128
	local suspStr = 32000

	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0, 0, suspLen),
		filter = filter,
	})


	if not noCheck then
		if tr.Hit and not can_collide[tr.Entity:GetCollisionGroup()] then
			filter[#filter + 1] = tr.Entity
			self:Stand(filter)
			return
		else
			self.StandItr = 0
		end
	end

	if not tr.Hit then
		self:SetGrounded(false)
		return
	end
	self:SetGrounded(true)

	local invdist = math.abs(tr.Fraction - 1) * (suspLen / 5)
	local force = suspStr * invdist + (suspDamp * (-self:GetVelocity().z))

	phys:ApplyForceCenter(Vector(0, 0, force / 2))

	-- lets slow down now
	local vel = phys:GetVelocity()
	phys:ApplyForceCenter(-vel * 64)

	-- need for playerstanding
	return tr
end

function ENT:ZombieChase(tr)
	if not self:GetStanding() then
		if self.HasWalkSound then
			self:StopSound("gmblox/bfsl-minifigfoots1.wav")
			self.HasWalkSound = false
		end

		return
	end

	if not IsValid(self.NearestPlayer) then
		if self.HasWalkSound then
			self:StopSound("gmblox/bfsl-minifigfoots1.wav")
			self.HasWalkSound = false
		end


		return
	end

	if self.NearestPlayer:Health() <= 0 then
		if self.HasWalkSound then
			self:StopSound("gmblox/bfsl-minifigfoots1.wav")
			self.HasWalkSound = false
		end

		return
	end

	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then
		return
	end

	local totalVel = Vector(0, 0, 0)

	totalVel = self.NearestPlayer:GetPos() - self:GetPos()
	totalVel:Normalize()

	local moved = totalVel:Length() > 0 and true or false


	if moved then
		if not self.HasWalkSound then
			self:EmitSound("gmblox/bfsl-minifigfoots1.wav")
			self.HasWalkSound = true
		end

		local vang = totalVel:Angle()
		self.targetAng = Angle(90, vang.y, 0)
	elseif self.HasWalkSound then
		self:StopSound("gmblox/bfsl-minifigfoots1.wav")
		self.HasWalkSound = false
	end

	local evel = Vector(0, 0, 0)
	if tr and tr.Hit and IsValid(tr.Entity) then
		evel = tr.Entity:GetVelocity()
	end

	local vcalc = (totalVel * 120) * self.WalkSpeedMult
	phys:SetVelocity(Vector(evel.x + vcalc.x, evel.y + vcalc.y, evel.z + phys:GetVelocity().z))


	if self.HasJumped and self:GetGrounded() then
		self.NextJump = CurTime() + 0.1
		self.HasJumped = false
	end


	if not self.targetFilter then
		return
	end

	if (self.NextJumpCheck or 0) > CurTime() then
		return
	end

	self.NextJumpCheck = CurTime() + 1


	local trJumpObstacle = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetUp() * 16 + self:GetForward() * 12,
		filter = self.targetFilter,
	})


	if trJumpObstacle.Hit and self:GetGrounded() and CurTime() > (self.NextJump or 0) and (not self.HasJumped) then
		if math.random(0, 1) == 1 then
			self:EmitSound("gmblox/button.wav")
			timer.Simple(math.Rand(0.05, 0.20), function()
				if not IsValid(self) then
					return
				end

				self:StopSound("gmblox/button.wav")
			end)
		end


		phys:ApplyForceCenter(Vector(0, 0, 44000 * self.JumpPowerMult))
		self.NextJump = CurTime() + 0.25
		self.HasJumped = true
		self:EmitSound("gmblox/jump.wav")
	end
end


function ENT:FallOverCheck()
	local ang = self:GetAngles()
	local diff = 30 -- 30 deg before falling over
	if ang.p > (90 + diff) or ang.p < (90 - diff) and self:GetStanding() and (CurTime() > (self.CanFallAgain or 0)) then
		self:SetStanding(false)
		self:SetGrounded(true)
		self:EmitSound("gmblox/splat.wav")
		timer.Simple(4, function()
			if not IsValid(self) then
				return
			end

			if self:GetHealthRoblox() <= 0 then
				return
			end

			self.CanFallAgain = CurTime() + 1
			self:SetStanding(true)
			self:EmitSound("gmblox/hit.wav")
		end)
	end
end
