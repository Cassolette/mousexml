local LinkedList = require("@mousetool/linkedlist")

--- A simple XML (de)serializer
local mousexml = {}

--- @alias XmlAttrValue string|number|boolean

--- Represents a collection of XML child nodes
--- @class XmlChildren : LinkedList
--- @field push_back fun(self:XmlChildren, value:XmlNode)
--- @field push_front fun(self:XmlChildren, value:XmlNode)
--- @field insert_after fun(self:XmlChildren, position:number, value:XmlNode)
--- @field pop_back fun(self:XmlChildren):XmlNode
--- @field pop_front fun(self:XmlChildren):XmlNode
--- @field back fun(self:XmlChildren):XmlNode
--- @field front fun(self:XmlChildren):XmlNode
--- @field get fun(self:XmlChildren, position:number):XmlNode
--- @field to_list fun(self:XmlChildren):XmlNode[]
--- @field to_reverse_list fun(self:XmlChildren):XmlNode[]

--- Represents an XML Node
--- @class XmlNode:Class
--- @field new fun(self:XmlNode, name:string):XmlNode
--- @field name string|nil
--- @field parent XmlNode|nil
--- @field children XmlChildren
--- @field attributes table<string, XmlAttrValue>
--- @field isDoc boolean #Whether this is a top-level root XML node
local XmlNode = require("@mousetool/class"):extend("XmlNode")
do
    XmlNode.isDoc = false

    --- @param name? string
    function XmlNode._init(self, name)
        self.name = name
        self.children = LinkedList.new()
        self.attributes = {}
    end

    --- Adds and links a child node to this parent node. Equivalent to:
    ---```lua
    --- node.parent = parent
    --- parent.children:push_back(node)
    --- ```
    --- @param node XmlNode The child node to add
    function XmlNode.addChild(self, node)
        node.parent = self
        self.children:push_back(node)
    end

    --- Converts the node into an XML string representation
    --- @return string
    function XmlNode.toXmlString(self)
        local attrs = {}
        for k, v in pairs(self.attributes) do
            attrs[#attrs+1] = k..'="'..v..'"'
        end
        local str = ("<%s%s"):format(self.name, #attrs > 0 and " " .. table.concat(attrs, " ") .. " " or "")
        if self.children.size > 0 then
            local cstr = {}
            local c = self.children:to_list()
            for i = 1, self.children.size do
                cstr[i] = c[i]:toXmlString()
            end
            str = str .. (">%s</%s>"):format(table.concat(cstr), self.name)
        else
            str = str .. "/>"
        end
        return str
    end
end

--- Represents an XML Document.
--- A document is assumed to be an anonymous top-level root XML Node, with no name, attributes or parent.
--- @class XmlDoc:XmlNode
--- @field new fun(self:XmlNode):XmlDoc
local XmlDoc = XmlNode:extend("XmlDoc")
do
    XmlDoc.isDoc = true

    --- Exports the document to an XML string representation
    --- @return string
    function XmlDoc.toXmlString(self)
        -- An XML document should only have one child
        if self.children.size > 0 then
            return self.children:front():toXmlString()
        end
        return ""
    end
end

--- Parses an XML string
--- @param xml string
--- @return XmlDoc?
function mousexml.parse(xml)
    local document = XmlDoc:new()
    local curr_node = document

    -- Parse nodes. will fail if attributes contain >, use a more robust parser to handle
    --- @type string
    for closing, name, attrib, leaf in xml:gmatch("<(/?)([%w_]+)(.-)(/?)>") do
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
    end
    if curr_node ~= document then return nil end
    return document
end

return mousexml
