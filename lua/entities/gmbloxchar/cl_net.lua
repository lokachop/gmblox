local function num2col(num)
	return Color(bit.band(num, 0xFF), bit.band(bit.rshift(num, 8), 0xFF), bit.band(bit.rshift(num, 16), 0xFF))
end

net.Receive("gmblox_changecolour_sv",  function()
	local target = net.ReadEntity()

	local colhead = num2col(net.ReadUInt(24))
	local colbody = num2col(net.ReadUInt(24))

	local coleftarm = num2col(net.ReadUInt(24))
	local colrightarm = num2col(net.ReadUInt(24))

	local colleftleg = num2col(net.ReadUInt(24))
	local colrightleg = num2col(net.ReadUInt(24))

	local ro = target.RenderObjects
	if not ro then
		return
	end

	ro["head"].col = colhead
	ro["torso"].col = colbody

	ro["leftleg"].col = colleftleg
	ro["rightleg"].col = colrightleg

	ro["leftarm"].col = coleftarm
	ro["rightarm"].col = colrightarm

	target:BuildCSModels()
end)

net.Receive("gmblox_changehat_sv", function()
	local target = net.ReadEntity()

	local hat = net.ReadString()
	local face = net.ReadString()


	local ro = target.RenderObjects
	if not ro then
		return
	end

	if not target.Faces[face] then
		return
	end

	target.ActiveFace = face or "normal"
	ro["head"].mat = target.Faces[face].mat
	target.ActiveHat = hat or "None"

	target:BuildCSModels()
end)


function ENT:SendSavedAppearance()
	local scolstr = cookie.GetString("gmblox_col")

	if not scolstr then
		return
	end

	local coltbl = util.JSONToTable(scolstr)
	if not coltbl then
		return
	end

	local colhead = coltbl.head
	local coltorso = coltbl.torso
	local coleftarm = coltbl.leftarm
	local colrightarm = coltbl.rightarm
	local colleftleg = coltbl.leftleg
	local colrightleg = coltbl.rightleg

	if not colhead or not coltorso or not coleftarm or not colrightarm or not colleftleg or not colrightleg then
		return
	end

	net.Start("gmblox_changecolour")
		net.WriteEntity(self)
		net.WriteUInt(colhead, 24)
		net.WriteUInt(coltorso, 24)
		net.WriteUInt(coleftarm, 24)
		net.WriteUInt(colrightarm, 24)
		net.WriteUInt(colleftleg, 24)
		net.WriteUInt(colrightleg, 24)
	net.SendToServer()



	local sprop = cookie.GetString("gmblox_prop")
	if not sprop then
		return
	end

	local prop = util.JSONToTable(sprop)

	if not prop then
		return
	end

	net.Start("gmblox_changehat")
		net.WriteEntity(self)
		net.WriteString(prop.hat)
		net.WriteString(prop.face)
	net.SendToServer()
end
