return function(token, model, price, additional_data)
    local lib = {}
    local LINK = "https://openrouter.ai/api/v1/chat/completions"
    local pool = requests.CreatePool(6, 0.05, 24)
    token = token or [[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]]

    local data = {
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer "..token
        },
        method = "POST",
        data = {
            ["model"] = model,
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
    if additional_data then
        for key, val in pairs(additional_data) do
            data.data[key] = val
        end
    end
    
    local megacallback = function(success, errcode, result, extra)
        if success then
            extra.kudos = math.ceil(result.usage.total_tokens / (price or 75))
            extra:callback(result.choices[1].message.content or " ")
        else
            extra:err("Error")
        end
    end

    function lib.Generate(messages, callback, errcallback, extra, stop_sequence)
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

    return lib
end