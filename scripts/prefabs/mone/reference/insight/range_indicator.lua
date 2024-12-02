---
--- @author zsh in 2023/4/7 1:08
---

local assets = {
    Asset("ANIM", "anim/insight_range_indicator.zip")
}

local MODES = {
    NORMAL = "firefighter_placemen",
    SMALL = "winona_battery_placemen",
}

local TEXTURES = {
    [MODES.NORMAL] = { SIZE = { 1900, 1900 } },
    [MODES.SMALL] = { SIZE = { 350, 350 } },
}

local PLACER_SCALE = 1.55
local ratio = 1 / PLACER_SCALE

local function ChangeIndicatorVisibility(inst, bool)
    if inst._anim == nil then
        error("ChangeIndicatorVisibility called without range indicator ._anim")
    end

    if bool then
        inst.AnimState:Show(inst._anim)
    else
        inst.AnimState:Hide(inst._anim)
    end
end

local function SetTextureMode(inst, mode)
    if inst._anim == mode then
        return
    end

    if inst._anim ~= nil then
        inst.AnimState:Hide(inst._anim)
    end

    inst._anim = mode

    if inst.is_visible then
        inst.AnimState:Show(inst._anim)
    end
end

local function SetRadius(inst, radius)
    local parent = inst.entity:GetParent()
    if not parent then
        error("attempt to call SetRadius with no entity parent")
        return
    end

    radius = radius * 4

    if radius <= 3 then
        SetTextureMode(inst, MODES.SMALL)
    else
        SetTextureMode(inst, MODES.NORMAL)
    end

    local scale = math.sqrt(radius * 300 / TEXTURES[inst._anim].SIZE[1])  -- the math.sqrt is a lucky guess. i was thinking along the lines of how SOMETHING (wortox soul detector but also the firefighter radius) needed to be reduced

    local a, b, c = 1, 1, 1
    if parent then
        a, b, c = parent.Transform:GetScale()
    end

    inst.Transform:SetScale(scale / a, scale / b, scale / c)
end

local function SetColour(inst, ...)
    if type(...) == "table" then
        inst.AnimState:SetMultColour(unpack(...))
    elseif select("#", ...) == 4 then
        inst.AnimState:SetMultColour(...)
    else
        error("SetColour not done properly: " .. tostring(inst) .. " | ")
    end
end

local function SetVisible(inst, bool)
    inst.is_visible = bool
    if inst.net_visible then
        inst.net_visible:set(bool)
    end

    if TheSim:GetGameID() == "DS" or TheNet:IsDedicated() == false then
        ChangeIndicatorVisibility(inst, bool)
    end
end

local function Attach(inst, to)
    inst.attached_to = to
    inst.entity:SetParent(to.entity)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")

    inst.AnimState:SetBank("bank_rt")
    inst.AnimState:SetBuild("insight_range_indicator")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    for i in pairs(TEXTURES) do
        inst.AnimState:Hide(i)
    end

    SetTextureMode(inst, MODES.NORMAL)

    inst.SetRadius = SetRadius
    inst.SetColour = SetColour
    inst.SetVisible = SetVisible
    inst.Attach = Attach

    inst:SetVisible(false)

    return inst
end

return Prefab("more_items_range_indicator", fn, assets);
