function on_player1_join(username)
    jakebox.update_ui(username, {
        {
            type = "text",
            content = "Waiting for another player to join"
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

function on_play(current_player, counter)
    jakebox.update_ui(current_player.username, {
        {
            type = "text",
            content = "The current number is " .. counter .. ". How much would you like to add?"
        },
        {
            type = "multiple_choice_input",
            key = tostring(counter),
            options = {
                "1",
                "2",
                "3"
            }
        }
    })
end

function win(username)
    jakebox.update_ui(username, {
        {
            type = "text",
            content = "You win!"
        }
    })
end

function lose(username)
    jakebox.update_ui(username, {
        {
            type = "text",
            content = "You lose!"
        }
    })
end

local counter = 0

local player1 = nil
local player2 = nil
local player2_playing = false

while true do
    local state = jakebox.get_state()
    for username, player in pairs(state.players) do
        if not player1 then
            player1 = player
            on_player1_join(username)
        elseif not player2 and username ~= player1.username then
            player2 = player
            on_play(player1, counter)
        elseif username ~= player1.username and username ~= player2.username then
            on_saturated_join(username)
        end
    end
    if player1 then
        player1 = state.players[player1.username]
    else 
    end
    if player2 then
        player2 = state.players[player2.username]
    end
    if player1 and player2 then
        local current_player = nil
        if player2_playing then
            current_player = player2
        else
            current_player = player1
        end
        local player_answer = current_player.event.data[tostring(counter)]
        if player_answer then
            player2_playing = not player2_playing
            if player2_playing then
                current_player = player2
            else
                current_player = player1
            end
            counter = counter + tonumber(player_answer) + 1
            if counter >= 21 then
                win(current_player.username)
                player2_playing = not player2_playing
                if player2_playing then
                    current_player = player2
                else
                    current_player = player1
                end
                lose(current_player.username)
                break
            end
            on_play(current_player, counter)
        end
    end
end
