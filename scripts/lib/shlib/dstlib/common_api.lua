---
--- Created by zsh
--- DateTime: 2023/10/1 0:31
---

setfenv(1, _G)
ShiHaoEnv.DstApi = {}

local DstApi = ShiHaoEnv.DstApi

function DstApi.IsValid(inst)
    return inst and inst.isValid and inst:IsValid()
end