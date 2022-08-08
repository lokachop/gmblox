ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "GMBlox - Zombie"
ENT.Spawnable = true
ENT.Category = "GMBlox"
ENT.Author = "Lokachop"
ENT.Contact = "Lokachop#5862 or lokachop@gmail.com"
ENT.Purpose = "A zombie for GMBlox"
ENT.Instructions = "Press use upon being spawned"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Standing")
	self:NetworkVar("Bool", 1, "Grounded")
	self:NetworkVar("Int", 0, "HealthRoblox")
end