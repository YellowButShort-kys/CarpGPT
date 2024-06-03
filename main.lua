function love.run()
	if love.load then love.load(love.parsedGameArguments, love.rawGameArguments) end
	if love.timer then love.timer.step() end
	return function()
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0, b
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
		local dt = love.timer and love.timer.step() or 0
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		if love.timer then love.timer.sleep(0.001) end
	end
end

function love.load()
    require("superdata")


    https = require("https")
    requests = require("extern.threaded_requests")
    sql = require("extern.sqlite3")



    openai = require("api.openai")
    capybara = require("api.capybara_free")
    translation = require("api.yandex")
    local OpenRouter = require("api.openrouter")
    llama8 = OpenRouter(nil, "meta-llama/llama-3-8b-instruct:free", 200)

    require("lang")


    local opn = sqlite3.open
    --KOBOLD = 3q7qnr2bMDMUo_5Yww4QHA
    --ANOTHER = 0000000000

    --local science = require("science")
    --ScienceCharUsage = science.New("log_charusage.csv", "%d; %t; %s")
    --ScienceTokenUsage = science.New("log_tokenusage.csv", "%d; %t; %s; %s")



    function prettyprint(table, key, indent)
        print( ("%s%s (%s): %s"):format(indent or "", key, type(table), tostring(table)) )
        if type(table) == "table" then
            for i, var in pairs(table) do
                prettyprint(var, i, (indent or "").."  ")
            end
        end
    end
    function shallowcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in pairs(orig) do
                copy[orig_key] = orig_value
            end
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end


    function sqlite3.open(...) --because fuck me
        local output = opn(...)
        if output then
            local db = getmetatable(output)
            local exe = db.exec
            function db:execute(str)
                local cringe
                local function wrapper(udata,cols,values,names)
                    cringe = cringe or {}
                    local t = {}
                    for i=1,cols do
                        t[names[i]] = values[i]
                    end
                    if cringe then
                        table.insert(cringe, t)
                    end
                    return 0
                end
                ---@diagnostic disable-next-line: redundant-parameter
                local code = exe(self, str, wrapper)
                if code ~= 0 then
                    print("SQL ERROR:")
                    print(code)
                    if type(code) == "table" then
                        prettyprint(code)
                    end
                    pcall(function()
                        print(output:errmsg())
                    end)
                end
                return cringe
            end
        end
        return output
    end
    function sqlite3.open_memory(...) --because fuck me
        local output = opn(...)
        if output then
            local db = getmetatable(output)
            local exe = db.exec
            function db:execute(str)
                local cringe
                local function wrapper(udata,cols,values,names)
                    cringe = cringe or {}
                    local t = {}
                    for i=1,cols do
                        t[names[i]] = values[i]
                    end
                    if cringe then
                        table.insert(cringe, t)
                    end
                    return 0
                end
                ---@diagnostic disable-next-line: redundant-parameter
                local code = exe(self, str, wrapper)
                if code ~= 0 then
                    print("SQL ERROR:")
                    print(code)
                    if type(code) == "table" then
                        prettyprint(code)
                    end
                    pcall(function()
                        print(output:errmsg())
                    end)
                end
                return cringe
            end
        end
        return output
    end


    local token = "6494795356:AAGhaFaBRptC8dMLQfJpeswsffo3efCMiVI"

    telelove = require("extern.Telelove")
    client = telelove.NewClient()
    client.active_chats = {}

    --FALLBACK = {}

    chats = require("chat")
    characters = require("characters")

    require("db")
    db_Init()
    db_Load()

    function client:onStart()
        commands = require("commands")
        client:RegisterMultipleCommands(commands.main_menu)
        --client:RegisterMultipleCommands(commands.chat_selection)
        --client:RegisterMultipleCommands(commands.new_chat)
    end

    client:Connect(token)
    function love.update()
        --love.timer.sleep(3)
        --db_Update()
        client:Update()
        --notifications()
        requests.Update()
    end
end