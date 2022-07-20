#if swift(>=5.5)
extension MIME:Sendable {}
extension MIME.Text:Sendable {}
extension MIME.TypeError:Sendable {}
#endif 

@frozen public 
enum MIME:Hashable, RawRepresentable, CustomStringConvertible
{
    public 
    struct TypeError:Error 
    {
        let expected:MIME, 
            encountered:MIME 
        public 
        init(_ encountered:MIME, expected:MIME)
        {
            self.expected = expected
            self.encountered = encountered
        }
    }
    
    @frozen public 
    enum Text:String, Hashable, RawRepresentable, CustomStringConvertible
    {
        case plain          = "text/plain"
        case markdown       = "text/markdown"
        case html           = "text/html"
        case css            = "text/css"
        case javascript     = "text/javascript"
        case json           = "application/json"
        case rss            = "application/rss+xml"
        case svg            = "image/svg+xml"
        
        @inlinable public 
        var `extension`:String 
        {
            switch self 
            {
            case .plain:        return "txt"
            case .markdown:     return "md"
            case .html:         return "html"
            case .css:          return "css"
            case .javascript:   return "js"
            case .json:         return "json"
            case .rss:          return "xml"
            case .svg:          return "svg"
            }
        }
        
        // does not include charset!
        @inlinable public 
        var description:String 
        {
            self.rawValue
        }
    }
    
    case utf8(encoded:Text)
    
    case woff2
    case otf
    case ttf
    case png
    case icon
    
    @inlinable public 
    init?(rawValue:String)
    {
        switch rawValue 
        {
        case "font/woff2":
            self = .woff2
        case "font/otf":
            self = .otf
        case "font/ttf":
            self = .ttf
        case "image/png":
            self = .png
        case "image/x-icon":
            self = .icon
        case let other: 
            if let text:Text = Text.init(rawValue: other)
            {
                self = .utf8(encoded: text)
            }
            else 
            {
                return nil
            }
        }
    }
    @inlinable public 
    var `extension`:String 
    {
        switch self 
        {
        case .utf8(encoded: let type):  return type.extension
        case .woff2:                    return "woff2"
        case .otf:                      return "otf"
        case .ttf:                      return "ttf"
        case .png:                      return "png"
        case .icon:                     return "ico"
        }
    }
    @inlinable public 
    var rawValue:String 
    {
        switch self
        {
        case .utf8(encoded: let text):  return text.description
        case .woff2:                    return "font/woff2"
        case .otf:                      return "font/otf"
        case .ttf:                      return "font/ttf"
        case .png:                      return "image/png"
        case .icon:                     return "image/x-icon"
        }
    }
    // includes charset!
    @inlinable public 
    var description:String 
    {
        if case .utf8(encoded: let type) = self 
        {
            return "\(type.description); charset=utf-8"
        }
        else
        {
            return self.rawValue 
        }
    }
}
