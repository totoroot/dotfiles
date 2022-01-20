VERSION = "1.1.6"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local util = import("micro/util")

function joinLines(v)
    local a, b, c = nil, nil, v.Cursor
    local selection = c:GetSelection()

    if c:HasSelection() then
        if c.CurSelection[1]:GreaterThan(-c.CurSelection[2]) then
            a, b = c.CurSelection[2], c.CurSelection[1]
        else
            a, b = c.CurSelection[1], c.CurSelection[2]
        end
        a = buffer.Loc(a.X, a.Y)
        b = buffer.Loc(b.X, b.Y)
        selection = c:GetSelection()
    else
        -- get beginning of curent line
        c:StartOfText()
        local startLoc = buffer.Loc(c.Loc.X, c.Loc.Y)  
        -- get the last position of the next line 
        -- I use the go function because Lua string.len counts bytes which leads
        -- to wrong results with some unicode characters
        local xNext = util.CharacterCountInString(v.Buf:Line(c.Loc.Y+1))

        a = startLoc
        b = buffer.Loc(xNext, c.Loc.Y+1)
        c:SetSelectionStart(startLoc)
        c:SetSelectionEnd(b)
        selection = c:GetSelection()
    end

    selection = util.String(selection)

    -- swap all whitespaces with a single space
    local modifiedSelection = string.gsub(selection, "%s+", " ")

    if util.CharacterCountInString(selection) > 0 then
        -- write modified selection to buffer
        v.Buf:Replace(a, b, modifiedSelection)
    else
        c:ResetSelection()
    end
end

function init()
    config.MakeCommand("joinLines", joinLines, config.NoComplete)
    config.TryBindKey("Alt-j", "lua:joinLines.joinLines", false)
    config.AddRuntimeFile("joinLines", config.RTHelp, "help/join-lines-plugin.md")
end
