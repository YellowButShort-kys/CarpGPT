local capybara = {}
local LINK = "https://openrouter.ai/api/v1/chat/completions"
local pool = requests.CreatePool(6, 0.05, 24)
local token = [[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]]

local data = {
    headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer "..token
    },
    method = "POST",
    data = {
        ["model"] = "nousresearch/nous-capybara-7b:free",
        ["max_tokens"] = 500,
        ["temperature"] = 0.8,
        --["top_p"] = 1,
        --["presence_penalty"] = 0,
        --["frequency_penalty"] = 0,
        ["stop"] = {"<|endoftext|>", "<START>", "<|eot_id|>"},
        ["messages"] = {
            
        }
    }
}
local megacallback = function(success, errcode, result, extra)
    if success then
        extra.kudos = math.ceil(result.usage.total_tokens / 200)
        extra:callback(result.choices[1].message.content or " ")
    else
        extra:err("Error")
    end
end

function capybara.Generate(messages, callback, errcallback, extra, stop_sequence)
    local old_messages = data["data"]["messages"]
    local old_stop = data["data"]["stop"]
    data["data"]["messages"] = messages
    data["data"]["stop"] = {}
    for _, var in ipairs(old_stop) do
        table.insert(data["data"]["stop"], var)
    end
    for _, var in ipairs(stop_sequence) do
        table.insert(data["data"]["stop"], var)
    end
    
    local task = {}
    task.err = errcallback
    task.callback = callback
    task.extra = extra
    
    pool:Request(LINK, data, megacallback, task)
    data["data"]["messages"] = old_messages
    data["data"]["stop"] = old_stop
    
    return task
end

return capybara