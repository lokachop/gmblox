function ENT:SetupCosRTs()
	local plyID = self:GetController():UserID()
	self.RenderRT = GetRenderTarget("gmblox_shirt_id_" .. plyID, 585, 559)

	self.MatNm = "gmblox_shirtmat_id_" .. plyID
	CreateMaterial(self.MatNm, "VertexLitGeneric", {
		["$basetexture"] = self.RenderRT:GetName(),
		["$model"] = 1,
	})

	self.HeadRenderRT = GetRenderTarget("gmblox_head_id_" .. plyID, 256, 256)
	self.HeadMatNm = "gmblox_headmat_id_" .. plyID
	CreateMaterial(self.HeadMatNm, "VertexLitGeneric", {
		["$basetexture"] = self.HeadRenderRT:GetName(),
		["$model"] = 1
	})

	self.PantsRenderRT = GetRenderTarget("gmblox_pants_id_" .. plyID, 585, 559)
	self.PantNm = "gmblox_pantsmat_id_" .. plyID
	CreateMaterial(self.PantNm, "VertexLitGeneric", {
		["$basetexture"] = self.PantsRenderRT:GetName(),
		["$model"] = 1,
	})

	self:RePaintRT()
	self:RetextureMat()
end


function ENT:RetextureMat()
	self.RenderObjects["torso"].mat = "!" .. self.MatNm
	self.RenderObjects["leftarm"].mat = "!" .. self.MatNm
	self.RenderObjects["rightarm"].mat = "!" .. self.MatNm

	self.RenderObjects["leftleg"].mat = "!" .. self.PantNm
	self.RenderObjects["rightleg"].mat = "!" .. self.PantNm

	self.RenderObjects["head"].mat = "!" .. self.HeadMatNm

	self.HasRT = true

	self:BuildCSModels()
end


local validRO = {
	["torso"] = true,
	["leftarm"] = true,
	["rightarm"] = true
}

local validROLeg = {
	["leftleg"] = true,
	["rightleg"] = true
}


local roPos = {
	["torso"] = {
		{x = 231, y = 74, w = 128, h = 128}, -- center "FRONT"
		{x = 427, y = 74, w = 128, h = 128}, -- back "BACK"
		{x = 165, y = 74, w = 64, h = 128}, -- right "R"
		{x = 361, y = 74, w = 64, h = 128}, -- left "L"
		{x = 231, y = 204, w = 128, h = 64}, -- bottom "DOWN"
		{x = 231, y = 8, w = 128, h = 64}, -- top "UP"
	},
	["leftarm"] = {
		{x = 308, y = 355, w = 64, h = 128}, -- center "F"
		{x = 374, y = 355, w = 64, h = 128}, -- left "L"
		{x = 440, y = 355, w = 64, h = 128}, -- back "B"
		{x = 506, y = 355, w = 64, h = 128}, -- right "R"
		{x = 308, y = 289, w = 64, h = 64}, -- top "U"
		{x = 308, y = 485, w = 64, h = 64}, -- bottom "D"
	},
	["rightarm"] = {
		{x = 217, y = 355, w = 64, h = 128}, -- center "F"
		{x = 151, y = 355, w = 64, h = 128}, -- right "R"
		{x = 85, y = 355, w = 64, h = 128}, -- back "B"
		{x = 19, y = 355, w = 64, h = 128}, -- left "L"
		{x = 217, y = 289, w = 64, h = 64}, -- top "U"
		{x = 217, y = 485, w = 64, h = 64}, -- bottom "D"
	},
	["leftleg"] = {
		{x = 308, y = 355, w = 64, h = 128}, -- center "F"
		{x = 374, y = 355, w = 64, h = 128}, -- left "L"
		{x = 440, y = 355, w = 64, h = 128}, -- back "B"
		{x = 506, y = 355, w = 64, h = 128}, -- right "R"
		{x = 308, y = 289, w = 64, h = 64}, -- top "U"
		{x = 308, y = 485, w = 64, h = 64}, -- bottom "D"
	},
	["rightleg"] = {
		{x = 217, y = 355, w = 64, h = 128}, -- center "F"
		{x = 151, y = 355, w = 64, h = 128}, -- right "R"
		{x = 85, y = 355, w = 64, h = 128}, -- back "B"
		{x = 19, y = 355, w = 64, h = 128}, -- left "L"
		{x = 217, y = 289, w = 64, h = 64}, -- top "U"
		{x = 217, y = 485, w = 64, h = 64}, -- bottom "D"
	}

}

local function render_rt_ez(rt, call)
	local oW, oH = ScrW(), ScrH()

	render.SetViewPort(0, 0, rt:GetMappingWidth(), rt:GetMappingHeight())
		cam.Start2D()
		render.PushRenderTarget(rt)
			pcall(call)
		render.PopRenderTarget()
		cam.End2D()
	render.SetViewPort(0, 0, oW, oH)
end

local function render_ro(k, v)
	if not roPos[k] then
		return
	end
	surface.SetDrawColor(v.col)
	for _, v2 in pairs(roPos[k]) do
		surface.DrawRect(v2.x - 1, v2.y - 1, v2.w + 2, v2.h + 2) -- fixes linear sampling error
	end
end

function ENT:RePaintRT()
	render_rt_ez(self.RenderRT, function()
		render_ro("torso", self.RenderObjects["torso"])

		if self.ActivePants and self.ActivePants ~= "none" then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(Material(GMBlox.ValidPants[self.ActivePants], "ignorez nocull alphatest smooth"))
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		for k, v in pairs(self.RenderObjects) do
			if k ~= "torso" then
				if not validRO[k] then
					continue
				end

				render_ro(k, v)
			end
		end


		if self.ActiveShirt and self.ActiveShirt ~= "none" then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(Material(GMBlox.ValidShirts[self.ActiveShirt], "ignorez nocull alphatest smooth"))
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)


	render_rt_ez(self.HeadRenderRT, function()
		surface.SetDrawColor(self.RenderObjects["head"].col)
		surface.DrawRect(0, 0, ScrW(), ScrH())

		local matFace = Material(self.Faces[self.ActiveFace], "nocull ignorez")
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(matFace)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end)

	render_rt_ez(self.PantsRenderRT, function()
		for k, v in pairs(self.RenderObjects) do
			if not validROLeg[k] then
				continue
			end

			render_ro(k, v)
		end

		if self.ActivePants and self.ActivePants ~= "none" then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(Material(GMBlox.ValidPants[self.ActivePants], "ignorez nocull alphatest smooth"))
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end)
end