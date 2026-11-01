function get_answer_key(game_state)
    return "ans" .. game_state.next_answer_key
end

function init_player(player, game_state)
    local answer_key = get_answer_key(game_state)
    jakebox.update_ui(player.username, {
        {
            type = "text",
            content = "You wake up in a deserted island. You don't immediately see anyone nearby, but you notice a light behind some palm trees. What do you do?"
        },
        {
            type = "text_input",
            key = answer_key,
            placeholder = "Type an answer..."
        }
    })
end

function on_saturated_join(username)
    jakebox.update_ui(username, {
        {
            type = "text",
            content = "This session is full."
        }
    })
end

function on_player_response(answer, player, game_state)
    local answer_key = get_answer_key(game_state)
    local action_block = {}
    for word in string.gmatch(answer, "%S+") do
        table.insert(action_block, word)
    end
    local action = parse_action(action_block)
    local response = nil
    local aliases = {
        go = "go to",
        move = "move",
        player = "yourself",
        tree = "the trees",
        light = "the light",
    }
    if action.action == "empty" or not action.action or not action.arguments or not action.arguments[1] then
        response = "I didn't understand that. Try again."
    else
        response = "You don't know how to " 
            .. tostring(aliases[action.action]) 
            .. " "
            .. tostring(aliases[action.arguments[1]]) 
            .. ". What do you do next?"
    end
    jakebox.update_ui(player.username, {
        {
            type = "text",
            content = response
        },
        {
            type = "text_input",
            key = answer_key,
            placeholder = "Type an answer..."
        }
    })
end

function parse_action(action)
    local action_words = {
        other = {
            go = {
                default = "go",
                other = {
                    to = { default = "go", other = {} },
                    toward = { default = "go", other = {} },
                    towards = { default = "go", other = {} },
                    into = { default = "go", other = {} },
                }
            },
            move = {
                default = "move",
                other = {
                    to = { default = "go", other = {} },
                    toward = { default = "go", other = {} },
                    towards = { default = "go", other = {} },
                    into = { default = "go", other = {} },
                }
            },
        }
    }
    local noun_words = {
        other = {
            me = { default = "player", other = {} },
            myself = { default = "player", other = {} },
            player = { default = "player", other = {} },
            trees = { default = "tree", other = {} },
            tree = { default = "tree", other = {} },
            palm = {
                default = "tree", 
                other = {
                    tree = { default = "tree", other = {} },
                    trees = { default = "tree", other = {} },
                }
            },
            light = { default = "light", other = {} },
        }
    }
    local filler_words = {
        "i",
        "the",
        "a",
        "an"
    }
    if #action > 0 then
        local noun_block, result_action = parse_word_block(action, action_words, filler_words, {})
        local _, result_argument = parse_word_block(noun_block, noun_words, filler_words, {})
        return {
            action = result_action,
            arguments = {result_argument}
        }
    end
    return {
        action = "empty"
    }
end

function parse_word_block(word_block, valid_words, filler_words, terminators)
    local current_path = {}
    while true do
        local found = false
        local default = valid_words.default
        for word, _ in pairs(valid_words.other) do
            if word_block[1] == word then
                table.insert(current_path, word)
                valid_words = valid_words.other[word]
                word_block = {table.unpack(word_block, 2, #word_block)}
                found = true
                break
            end
        end
        if not found then
            for _, filler_word in ipairs(filler_words) do
                if word_block[1] == filler_word then
                    word_block = {table.unpack(word_block, 2, #word_block)}
                    found = true
                    break
                end
            end
        end
        if not found then
            for _, terminator in ipairs(terminators) do
                if word_block[1] == terminator then
                    word_block = {table.unpack(word_block, 2, #word_block)}
                    break
                end
            end
        end
        if not found then
            return word_block, default
        end
    end
end

local player1 = nil

local game_state = {
    next_answer_key = 0
}

while true do
    local state = jakebox.get_state()
    for username, player in pairs(state.players) do
        if not player1 then
            player1 = username
            init_player(player, game_state)
        elseif player1 ~= username then
            on_saturated_join(username)
        end
    end
    if player1 then
        local player = state.players[player1]

        local current_answer = player.event.data[get_answer_key(game_state)]
        if current_answer then
            game_state.next_answer_key = game_state.next_answer_key + 1
            on_player_response(current_answer, player, game_state)
        end
    end
    sleep(1)
end
