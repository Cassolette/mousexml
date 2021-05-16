local LinkedList = require("@mousetool/linkedlist")

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
--- @alias XmlChildrenIter fun(_: LinkedListNode, i?: integer):integer, XmlNode
--- @field ipairs fun(self:XmlChildren):XmlChildrenIter, LinkedListNode, integer
--- @field to_list fun(self:XmlChildren):XmlNode[]
--- @field to_reverse_list fun(self:XmlChildren):XmlNode[]

--- Represents an XML Node
--- @class XmlNode:Class
--- @overload fun(name:string):XmlNode
--- @field new fun(self:XmlNode, name:string):XmlNode
--- @field name string|nil
--- @field parent XmlNode|nil
--- @field children XmlChildren
--- @field text string|nil
--- @field attributes table<string, string>
--- @field isDoc boolean #Whether this is a top-level root XML node
local XmlNode = require("@mousetool/class"):extend("XmlNode")
do
    XmlNode.isDoc = false

    --- @param name? string
    function XmlNode._init(self, name)
        self.name = name
        self.children = LinkedList.new()
        self.attributes = {}

        -- When this object is invoked via call, direct it to findChild()
        getmetatable(self).__call = function(self, name)
            return self:findChild(name)
        end
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

    --- Finds child nodes with the matching name
    --- @param name string
    --- @return XmlNode[]
    function XmlNode.findChildren(self, name)
        local result = {}  --- @type XmlNode[]
        local result_sz = 0

        for i,
                child  --- @type XmlNode
                in self.children:ipairs() do
            if child.name == name then
                result_sz = result_sz + 1
                result[result_sz] = child
            end
        end

        return result
    end

    --- Finds child node(s) with the matching name. Similar to `findChildren`, but returns:
    ---  - `XmlNode` when only a single child exists
    ---  - `nil` when no children exists
    ---  - `XmlNode[]` when multiple children exists
    --- @see XmlNode.findChildren
    --- @param name string
    --- @return XmlNode|XmlNode[]|nil
    function XmlNode.findChild(self, name)
        local children = self:findChildren(name)
        local children_count = #children
        if children_count > 1 then
            return children
        elseif children_count == 1 then
            return children[1]
        end
        return nil
    end

    --- Converts the node into an XML string representation
    --- @return string
    function XmlNode.toXmlString(self)
        local attrs = {}
        for k, v in pairs(self.attributes) do
            attrs[#attrs+1] = k .. '="' .. v .. '"'
        end
        local inner_text, inner_text_sz = {}, 0
        if self.text then
            inner_text_sz = inner_text_sz + 1
            inner_text[inner_text_sz] = self.text
        end
        if self.children.size > 0 then
            local c = self.children:to_list()
            for i = 1, self.children.size do
                inner_text_sz = inner_text_sz + 1
                inner_text[inner_text_sz] = c[i]:toXmlString()
            end
        end
        return
            ("<%s%s"):format(self.name, #attrs > 0 and " " .. table.concat(attrs, " ") or "") ..
            (
                inner_text_sz > 0 and
                (">%s</%s>"):format(table.concat(inner_text, nil, nil, inner_text_sz), self.name) or
                " />"  -- Self-closing
            )
    end
end

return XmlNode
