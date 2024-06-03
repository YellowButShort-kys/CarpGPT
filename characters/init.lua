local characters = {}
local hub = {}
local hub_tags = {}
local tags = {}
local base = {}

function characters.LoadCharacters()
    
end

function characters.GetCharacter(id)
    return hub[id]
end

function characters.GetHub()
    return hub
end

local cwd = ...
local weekly
local function RegisterChar(path)
    local t = require(cwd .. "." .. path)
    setmetatable(t, {__index = base})
    t.id = #hub+1
    table.insert(hub, t)
    weekly = t
end

RegisterChar("kostil")

local _tags = {}
for _, var in ipairs(hub) do
    for _, tag in ipairs(var.tags) do
        if not hub_tags[tag] then hub_tags[tag] = {} end
        if not _tags[tag] then _tags[tag] = true end
        table.insert(hub_tags[tag], var)
    end
end
for i, var in pairs(_tags) do
    table.insert(tags, i)
end
_tags = nil

function characters.GetTagged()
    return hub_tags
end
function characters.GetTags()
    return tags
end

function characters.GetWeekly()
    return weekly
end

-------------------------------------------------------------
--------------------------- base ----------------------------
-------------------------------------------------------------

base.starter = [[
Below is an instruction that describes a task. Write a response that appropriately completes the request.

Write {{char}}'s next reply in a fictional roleplay chat between {{char}} and {{user}}.

{{char}}'s Persona: 
%s

The scenario of the conversation: 
%s

This is how {{char}} should talk: 
%s

***  

### Response:
{{char}}: %s
]]

base.name = "Robot"
base.description = "Test"
base.persona = [[
Name: Robot
species: robot
mind: kind, compassionate, caring, tender, forgiving, enthusiastic
personality: kind, compassionate, caring, tender, forgiving, enthusiastic
]]
base.system = [[you are ChatGPT, a large language model trained by OpenAI]]
base.example = [[
{{user}}: I have some big and important news to share!
{{char}}: *{{user}} appears genuinely excited* What is the exciting news?
]]
base.scenario = [[]]
base.greeting = [[
*A soft smile appears on {{char}}'s face as {{user}} enters the cafe and takes a seat* *Beep! Boop!* Hello, {{user}}! It's good to see you again. What would you like to chat about?
]]

function base:GetStarter(user)
    return (self.starter:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetFirstMessage(user)
    return (self.greeting:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetSystem(user)
    return (self.system:gsub("{{user}}", GetUserName(user)):gsub("{{char}}", self.name))
end

function base:GetHistory()
    return self.history
end

function base:GetName()
    return self.name
end
function base:GetDisplayName(lang)
    return self.display_name[lang]
end

function base:FormatMessage(chat, str)
    return str
end
function base:FormatOutput(chat, str)
    return str
end
return characters