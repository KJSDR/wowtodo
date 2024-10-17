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
    scrollFrame:SetSize(280, 300) 
    scrollFrame:SetPoint("TOP", 0, -40)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(280, 300)
    scrollFrame:SetScrollChild(contentFrame)

    local function SaveItems()
        todolistDB.items = todoItems
    end

    local function UpdateList()
        for i, child in ipairs({contentFrame:GetChildren()}) do
            child:Hide()
        end

        local itemHeight = 20 
        local spacing = 5   
        local totalHeight = 0 
        
        for i, item in ipairs(todoItems) do
            local checkbox = CreateFrame("CheckButton", nil, contentFrame, "ChatConfigCheckButtonTemplate")
            checkbox:SetPoint("TOPLEFT", 10, -totalHeight - spacing)
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

            totalHeight = totalHeight + itemHeight + spacing
        end

        contentFrame:SetSize(frame:GetWidth() - 20, totalHeight)
        scrollFrame:SetSize(frame:GetWidth() - 20, 300)

        if totalHeight < 300 then
            contentFrame:SetHeight(totalHeight)
        else
            contentFrame:SetHeight(300)
        end
    end

    local editBoxBackground = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    editBoxBackground:SetSize(210, 25)
    editBoxBackground:SetPoint("BOTTOMLEFT", 10, 10)
    editBoxBackground:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    editBoxBackground:SetBackdropColor(0, 0, 0, 0.5)

    local editBox = CreateFrame("EditBox", nil, editBoxBackground)
    editBox:SetSize(200, 20)
    editBox:SetPoint("CENTER")
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

    editBox:SetTextInsets(5, 5, 0, 0)

    
    local resizeHandle = CreateFrame("Frame", nil, frame)
    resizeHandle:SetSize(16, 16) -- Size of the handle
    resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    resizeHandle:EnableMouse(true)

    
    local handleTexture = resizeHandle:CreateTexture(nil, "OVERLAY")
    handleTexture:SetAllPoints()
    handleTexture:SetColorTexture(0.2, 0.2, 0.2, 0.5) 

    resizeHandle:SetScript("OnMouseDown", function(self)
        frame:StartSizing("BOTTOMRIGHT")
    end)

    resizeHandle:SetScript("OnMouseUp", function(self)
        frame:StopMovingOrSizing()
        UpdateList() 
    end)

    
    frame:SetResizable(true)

    
    frame:SetScript("OnSizeChanged", function(self)
        local width = self:GetWidth()
        
        
        editBoxBackground:SetWidth(width - 20)
        editBox:SetWidth(width - 30)

        scrollFrame:SetSize(width - 20, 300)
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
