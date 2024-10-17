local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
    todolistDB = todolistDB or { items = {} }
    todoItems = todolistDB.items

    print("Loaded todoItems:")
    for i, item in ipairs(todoItems) do
        print(i, item.text, item.checked)
    end

    local frame = CreateFrame("Frame", "ToDoListFrame", UIParent)
    frame:SetSize(300, 400)
    frame:SetPoint("CENTER")
    frame:Hide()

    local bgTexture = frame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    bgTexture:SetAllPoints(frame)

    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -5, 5)
    border:SetPoint("BOTTOMRIGHT", 5, -5)
    border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("To Do List")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(280, 320)
    scrollFrame:SetPoint("TOP", 0, -40)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(280, 320)
    scrollFrame:SetScrollChild(contentFrame)

    local function SaveItems()
        todolistDB.items = todoItems
    end

    local function UpdateList()
        for i, child in ipairs({contentFrame:GetChildren()}) do
            child:Hide()
        end

        for i, item in ipairs(todoItems) do
            local checkbox = CreateFrame("CheckButton", nil, contentFrame, "ChatConfigCheckButtonTemplate")
            checkbox:SetPoint("TOPLEFT", 10, -20 * (i - 1))
            checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5)
            checkbox.text:SetText(item.text)
            checkbox:SetChecked(item.checked)

            checkbox:SetScript("OnClick", function(self)
                item.checked = self:GetChecked()
                SaveItems() 
            end)

            local removeButton = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
            removeButton:SetSize(25, 20)
            removeButton:SetText("-")
            removeButton:SetPoint("LEFT", checkbox.text, "RIGHT", 5, 0)

            local itemIndex = i 
            removeButton:SetScript("OnClick", function()
                table.remove(todoItems, itemIndex)
                UpdateList()
                SaveItems()
            end)

            removeButton:SetFrameLevel(checkbox:GetFrameLevel() + 1)
        end

        local frameWidth, frameHeight = frame:GetSize()
        contentFrame:SetSize(frameWidth - 20, frameHeight - 80)
        scrollFrame:SetSize(frameWidth - 20, frameHeight - 40)
    end

    local editBox = CreateFrame("EditBox", nil, frame)
    editBox:SetSize(200, 20)
    editBox:SetPoint("BOTTOM", 0, 10)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEnterPressed", function(self)
        local newItemText = self:GetText()
        if newItemText ~= "" then
            table.insert(todoItems, {text = newItemText, checked = false})
            self:SetText("")
            UpdateList()
            SaveItems()
        end
    end)

    local decreaseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    decreaseButton:SetSize(25, 25)
    decreaseButton:SetText("-")
    decreaseButton:SetPoint("TOPRIGHT", -35, -10)

    decreaseButton:SetScript("OnClick", function()
        local width, height = frame:GetSize()
        if width > 200 and height > 200 then
            frame:SetSize(width - 20, height - 20)
            UpdateList()
        end
    end)

    local increaseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    increaseButton:SetSize(25, 25)
    increaseButton:SetText("+")
    increaseButton:SetPoint("TOPRIGHT", -5, -10)

    increaseButton:SetScript("OnClick", function()
        local width, height = frame:GetSize()
        frame:SetSize(width + 20, height + 20) 
        UpdateList() 
    end)

    SLASH_TODOLIST1 = "/todolist"
    SlashCmdList["TODOLIST"] = function()
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    UpdateList()
end)
