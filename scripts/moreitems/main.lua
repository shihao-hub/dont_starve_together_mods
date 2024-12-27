---
--- DateTime: 2024/12/3 10:04
--- Description: 项目启动入口，放在模组中，则视为第三方库引入入口
---

require("moreitems.preload")

local dkjson = require("lib.dkjson.dkjson")
local json = require("lib.json.json")
local inspect = require("lib.inspect.inspect")
local fun = require("lib.luafun.fun")

local log = require("lib.shihao.module.log")
local utils = require("lib.shihao.utils")

local settings = require("settings")

return {
    dkjson = dkjson,
    json = json,
    inspect = inspect,
    fun = fun,

    log = log,
    utils = utils,

    settings = settings,

    dst = require("lib.dst.init")
}


