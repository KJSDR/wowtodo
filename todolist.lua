local ToDoListFrame = CreateFrame("Frame", "ToDoListFrame", UIParent)
ToDoListFrame:SetSize(300, 400)
ToDoListFrame:SetPoint("CENTER")
ToDoListFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
ToDoListFrame:SetBackdropColor(0, 0, 0, 1)
ToDoListFrame:Show()  -- Start hidden

local title = ToDoListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("To-Do List")

local tasks = {}

local function UpdateTaskList()
    for i, task in ipairs(tasks) do
        local taskFrame = _G["ToDoListTask" .. i]
        if not taskFrame then
            taskFrame = ToDoListFrame:CreateFontString("ToDoListTask" .. i, "OVERLAY", "GameFontNormal")
            taskFrame:SetPoint("TOPLEFT", 10, -30 - (i - 1) * 20)
        end
        taskFrame:SetText(task)
    end
end

local function AddTask(task)
    if task and task ~= "" then
        table.insert(tasks, task)
        UpdateTaskList()
        print("Added task: " .. task)
    else
        print("Please enter a valid task.")
    end
end

SLASH_TODOLIST1 = "/todolist"
function SlashCmdList.TODOLIST(msg)
    if msg == "toggle" then
        if ToDoListFrame:IsShown() then
            ToDoListFrame:Hide()
        else
            ToDoListFrame:Show()
        end
    else
        AddTask(msg)
    end
end

ToDoListFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
ToDoListFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

-- Show the frame when the player logs in
ToDoListFrame:Show()  -- This line shows the frame initially
