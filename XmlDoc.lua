local XmlNode = require("XmlNode")

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

return XmlDoc
