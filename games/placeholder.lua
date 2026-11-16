local player_count = 0

function on_player_join(player) 
    player_count = player_count + 1
    jakebox.update_host_ui({
        {
            type = "text",
            content = "Player count: " .. player_count
        }
    })
    if #player.event.ui == 0 then
        jakebox.update_ui(player.username, {
            {
                type = "text",
                content = "Does it work?"
            },
            {
                type = "text_input",
                key = "answer",
                placeholder = "Type an answer..."
            }
        })
    end
end

function on_player_submit(player, key, value)
    if key == "answer" and value == "yes" then
        jakebox.update_ui(player.username, {
            {
                type = "text",
                content = "Yay!!!"
            }
        })
    end
end

jakebox.on_event("player_join", on_player_join)
jakebox.on_event("player_submit", on_player_submit)

while true do
    jakebox.update_events()
    sleep(0.5)
end