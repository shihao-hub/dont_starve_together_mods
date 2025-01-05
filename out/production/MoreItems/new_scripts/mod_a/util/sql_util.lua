---
--- Created by zsh
--- DateTime: 2023/11/7 5:27
---

-- The code in here is not available and useful, because they depend on Lua for Windows.

require("new_scripts.mod_a.main")

require("new_scripts.mod_a.class")
local Class = morel_Class
local Module = morel_Module

local util = Module()
function util.db_insert(conn, table_name, website)
    local command = string.format("insert into %s%s", table_name, website:to_db_command_format())
    --print(command)
    return assert(conn:execute(command))
end

local config = {
    file_path_root = "new_scripts/mod_a/",
    data_base_name = "java",
    account_name = "root",
    password = "zsh20010417",
}

local function env_connect(env, sourcename, username, password, hostname, port)
    local conn = env:connect(sourcename, username, password, hostname, port)
    --conn.__index.data_base_name = sourcename
    return conn
end

local mysql_driver = assert(require("luasql.mysql"))
local env = assert(mysql_driver.mysql())
local conn = assert(env_connect(env, config.data_base_name, config.account_name, config.password))

---@class DB_Website
---@field id:number,name:string,url:string,alexa:number,country:string
local DB_Website = Class(function(self, id, name, url, alexa, country)
    self.id = id
    self.name = name
    self.url = url
    self.alexa = alexa
    self.country = country

    function self:to_db_command_format()
        return string.format("(id,name,url,alexa,country) values(%d,'%s','%s',%d,'%s')",
                self.id, self.name, self.url, self.alexa, self.country)
    end
end)

local website_zhihu = DB_Website:new(12, "zhihu10", "https://www.zhihu.com/", 100, "China")
util.db_insert(conn, "websites", website_zhihu)




