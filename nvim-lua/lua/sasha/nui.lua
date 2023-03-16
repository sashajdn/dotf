local ok, nui = pcall(require, "nui")
if not ok then
    return
end

local popup_ok, popup = pcall(require, "nui.popup")
if not popup_ok then
    return
end

popup({
    border = {
        style = "none",
    },
    position = 50,
    win_options = {
        winhighlight = {
            Normal = "NormalFloat",
            FloatBorder = "FloatBorder",
        }
    }
})
