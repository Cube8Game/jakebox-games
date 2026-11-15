while true do
    local state = jakebox.get_state()
    local player_count = 0
    for _, player in pairs(state.players) do
        player_count = player_count + 1
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
        elseif player.event.data.answer == "yes" then
            jakebox.update_ui(player.username, {
                {
                    type = "text",
                    content = "Yay!!!"
                }
            })
        end
    end
    jakebox.update_host_ui({
        {
            type = "text",
            content = "Player count: " .. player_count
        }
    })
    sleep(2)
end