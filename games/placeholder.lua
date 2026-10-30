while true do
    local state = jakebox.get_state()
    for _, player in pairs(state.players) do
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
    sleep(2)
end