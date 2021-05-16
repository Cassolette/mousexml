--- A simple XML (de)serializer
local mousexml = {}

local XmlNode = require("XmlNode")
local XmlDoc = require("XmlDoc")

--- Parses an XML string
--- @param xml string
--- @return XmlDoc?
function mousexml.parse(xml)
    local document = XmlDoc:new()
    local curr_node = document

    -- Parse nodes. will fail if attributes contain >, use a more robust parser to handle
    --- @type string
    for closing, name, attrib, leaf, text in xml:gmatch("<(/?)([%w_]+)(.-)(/?)>%s*([^<]*)%s*") do
        if closing == "/" then
            if curr_node == nil or curr_node == document then return nil end
            if leaf == "/" then return nil end  -- </Name/> doesn't make sense
            if name ~= curr_node.name then return nil end  -- <a></b> doesn't make sense
            if attrib ~= "" then return nil end  -- </Name a="b"> doesn't make sense

            curr_node = curr_node.parent  -- go up one level
        else
            -- Make a new node
            local node = XmlNode:new(name)

            -- Parse attributes
            for k, v in attrib:gmatch([[%s([%a_:][^%s%c]-)%s*=%s*"(.-)"]]) do -- attribute key/value matching. will fail if attribute value contain " (through escaping), use a more robust parser to handle
                node.attributes[k] = v
            end

            curr_node:addChild(node)

            if leaf == "" then
                -- Not a self-closing tag
                curr_node = node
            end
        end

        if text ~= "" then
            -- Link the text to the current node. If a text is already linked, append this one with a space.
            local curr_text = curr_node.text
            curr_node.text = (curr_text and curr_text .. " " or "") .. text
        end
    end
    if curr_node ~= document then return nil end
    return document
end

mousexml.XmlNode = XmlNode
mousexml.XmlDoc = XmlDoc

return mousexml
