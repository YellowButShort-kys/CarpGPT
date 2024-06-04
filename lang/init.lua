LANG = {}
local default = {__index = function(self, key) return LANG["en"][key] end}
require("lang.en")
require("lang.ru")
require("lang.ua")
setmetatable(LANG["en"], {__index = function(self, key) return key end})
setmetatable(LANG["ru"], default)
setmetatable(LANG["ua"], default)

LANG[1] = LANG["en"]
LANG[2] = LANG["ru"]
LANG[3] = LANG["ua"]