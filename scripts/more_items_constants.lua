local module = {
    LIFE_INJECTOR_VB__INCLUDED_PLAYERS = {
        -- 排除 旺达、机器人、小鱼人
        "wilson", "willow", "wolfgang", "wendy", "wickerbottom", "woodie", "wes", "waxwell",
        "wathgrithr", "webber", "winona", "warly", "wortox", "wormwood", "wonkey", "walter",
        -- 加回 机器人
        "wx78", --[["wurt","wanda",]] -- 旺达和小鱼人有点不好处理
        "jinx", -- https://steamcommunity.com/sharedfiles/filedetails/?id=479243762
        "monkey_king", "neza", "white_bone", "pigsy", "yangjian", "myth_yutu", "yama_commissioners", "madameweb",
    },
    LIFE_INJECTOR_VB__PER_ADD_NUM = 10,

    SINGLE_DOG__DETECTION__CYCLE_LENGTH = 1,
    SINGLE_DOG__DETECTION__RADIUS = 15,
    SINGLE_DOG__DETECTION__MUST_TAGS = { "hound" },
    SINGLE_DOG__DETECTION__CANT_TAGS = nil,
    SINGLE_DOG__DETECTION__MUST_ONE_OF_TAGS = nil,
    SINGLE_DOG__DETECTION__BLEEDING_PERCENTAGE = 0.2,
    SINGLE_DOG__OBSTACLE_PHYSICS_HEIGHT = 0.3,
    SINGLE_DOG__WORK_LEFT = 3,
    SINGLE_DOG__PREFAB_NAME = "mone_single_dog",
    SINGLE_DOG__PREFAB_CHINESE_NAME = "单身狗",
}

return module