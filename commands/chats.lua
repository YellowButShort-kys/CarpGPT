---@param langcode string
---@return table
return function(langcode, menu)
    local chats_button = client:NewInlineKeyboardButton()
    chats_button.text = LANG[langcode]["$MAIN_MENU_CHATS"]
    
    local new_chat = client:NewInlineKeyboardButton()
    do --new_chat
        local chars = {}
        local ikm = client:NewInlineKeyboardMarkup()
        for _, var in ipairs(characters.GetHub()) do
            local button_more = client:NewInlineKeyboardButton()
            button_more.text = var.display_name[langcode] or var.name
            button_more.char = var
            button_more.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, (var.display_name[langcode] or var.name)..":\n"..var.description[langcode], self.ikm)
            end
            
            
            button_more.ikm = client:NewInlineKeyboardMarkup()  
            
            
            local btn_select = client:NewInlineKeyboardButton()
            btn_select.text = LANG[langcode]["$NEW_CHAR_SELECT"]
            btn_select.char = var
            btn_select.callback = function(self, query)
                if not chats.GetUserChat(query.from, self.char) then 
                    client.active_chats[query.from.id] = chats.NewChat(query.from, self.char)
                    client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(self.char:GetFirstMessage(query.from), "en", langcode)))
                    --ScienceCharUsage(self.char:GetName())
                else
                    client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_REWRITE"], self.rewrite)
                end
            end
            
            local btn_rewrite_confirm = client:NewInlineKeyboardButton()
            btn_rewrite_confirm.text = LANG[langcode]["$NEW_CHAR_CONFIRM"]
            btn_rewrite_confirm.owner = btn_select
            btn_rewrite_confirm.callback = function(self, query)
                --chats.DeleteUserChat(query.from, self.owner.char)
                --client.active_chats[query.from.id] = chats.NewChat(query.from, self.owner.char)
                client.active_chats[query.from.id] = chats.GetUserChat(query.from, self.owner.char)
                --client.active_chats[query.from.id]:SetContent(self.owner.char:GetStarter(query.from))
                client.active_chats[query.from.id]:ResetChat()
                client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(self.owner.char:GetFirstMessage(query.from), "en", langcode)))
                --ScienceCharUsage(self.owner.char:GetName())
            end
            

            local btn_back = client:NewInlineKeyboardButton()
            btn_back.text = LANG[langcode]["$NEW_CHAR_BACK"]
            btn_back.callback = function(self, query)
                new_chat:callback(query)
            end
            button_more.ikm.inline_keyboard = {{btn_back, btn_select}}
            
            btn_select.rewrite = client:NewInlineKeyboardMarkup()
            btn_select.rewrite.inline_keyboard = {{btn_back, btn_rewrite_confirm}}
            for _, tag in ipairs(var.tags) do
                if not chars[tag] then
                    chars[tag] = {}
                end
                table.insert(chars[tag], button_more)
            end
            
            if var == characters.GetWeekly() then
                local btn = button_more
                btn.text = LANG[langcode]["$NEW_CHAR_WEEKLY"]:format(var:GetDisplayName(langcode))
                table.insert(ikm.inline_keyboard, {btn})
            end
        end
        
        
        local btns = {}
        for tag, var in pairs(chars) do
            local tagikm = client:NewInlineKeyboardMarkup()
            local counter = 1
            while true do
                if not var[counter] then break end
                table.insert(tagikm.inline_keyboard, {
                    var[counter],
                    var[counter+1],
                    var[counter+2],
                })
                counter = counter + 3
            end
            local back = client:NewInlineKeyboardButton()
            back.text = LANG[langcode]["$NEW_CHAR_BACK"]
            back.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], ikm)
            end
            table.insert(tagikm.inline_keyboard, {})
            table.insert(tagikm.inline_keyboard, {back})
            
            local button = client:NewInlineKeyboardButton()
            button.text = tag
            button.callback = function(self, query)
                client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], tagikm)
            end
            table.insert(btns, button)
        end
        local counter = 1
        
        while true do
            if not btns[counter] then break end
            table.insert(ikm.inline_keyboard, {
                btns[counter],
                btns[counter+1],
                btns[counter+2],
            })
            counter = counter + 3
        end
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$NEW_CHAR_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        end
        table.insert(ikm.inline_keyboard, {back})
        
        new_chat.text = LANG[langcode]["$NEW_CHAR"]
        new_chat.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$NEW_CHAR_MSG"], ikm)
        end
    end
    
    local load_chat = client:NewInlineKeyboardButton()
    do --load_chat
        local available_chats = {}
        for _, var in ipairs(characters.GetHub()) do
            local button = client:NewInlineKeyboardButton()
            button.text = var.name
            button.char = var
            button.callback = function(self, query)
                local chat = chats.GetUserChat(query.from, self.char)
                if chat then
                    client:EditMessageText(query.message.chat, query.message, htmlformat(translation.Translate(chat:GetLastResponse(), "en", langcode)))
                    client.active_chats[query.from.id] = chat
                end
            end
            
            table.insert(available_chats, button)
        end
        
        local back = client:NewInlineKeyboardButton()
        back.text = LANG[langcode]["$LOAD_CHAR_BACK"]
        back.callback = function(self, query)
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$INTRODUCTION"], menu)
        end
        
        load_chat.text = LANG[langcode]["$LOAD_CHAR"]
        load_chat.callback = function(self, query)
            local ikm = client:NewInlineKeyboardMarkup()
            ikm.inline_keyboard = {{}}
            
            local user_chats = chats.GetChats(query.from)
            local translated = {}
            for x = 1, #available_chats do
                translated[x] = user_chats[x] and 1 or 0
            end
            
            for i, var in ipairs(translated) do
                if var == 1 then
                    if #ikm.inline_keyboard[#ikm.inline_keyboard] > 3 then
                        table.insert(ikm.inline_keyboard, {})
                    end
                    table.insert(ikm.inline_keyboard[#ikm.inline_keyboard], available_chats[i])
                end
            end
            table.insert(ikm.inline_keyboard, {back})
            
            client:EditMessageText(query.message.chat, query.message, LANG[langcode]["$LOAD_CHAR_MSG"], ikm)
        end
    end
    
    return chats_button
end