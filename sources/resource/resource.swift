public 
protocol ServiceBackend 
{
    associatedtype Request
    associatedtype Endpoint
    associatedtype Continuation where Continuation:Sendable
    
    func request(_ request:Request) -> DynamicResponse<Endpoint>
    func request(_ endpoint:Endpoint, continuation:Continuation) 
}

@frozen public 
enum StaticResponse:Sendable 
{
    case none(Resource)
    
    case maybe(canonical:String, at:String)
    case found(canonical:String, at:String)
    case matched(canonical:String, Resource)
}
@frozen public 
enum DynamicResponse<Endpoint>:Sendable where Endpoint:Sendable
{
    case immediate(StaticResponse)
    case enqueue(to:Endpoint)
}

@frozen public 
struct Resource:Sendable 
{
    public 
    struct TypeError:Error 
    {
        let expected:Binary, 
            encountered:Binary 
        public 
        init(_ encountered:Binary, expected:Binary)
        {
            self.expected = expected
            self.encountered = encountered
        }
    }
    @frozen public 
    enum Payload:Sendable 
    {
        case text   (String,  type:Text)
        case binary ([UInt8], type:Binary) 
    }
    
    public 
    let payload:Payload 
    public 
    var tag:Tag?
    
    @inlinable public static
    func text(_ string:String, type:Text = .plain, tag:Tag? = nil) -> Self
    {
        .init(.text(string, type: type), tag: tag)
    }
    @inlinable public static
    func binary(_ bytes:[UInt8], type:Binary, tag:Tag? = nil) -> Self
    {
        .init(.binary(bytes, type: type), tag: tag)
    }
    @inlinable public static
    func utf8(encoded bytes:[UInt8], type:Text = .plain, tag:Tag? = nil) -> Self
    {
        .binary(bytes, type: .utf8(encoded: type), tag: tag)
    }
    @inlinable public 
    init(_ payload:Payload, tag:Tag?) 
    {
        self.payload = payload 
        self.tag = tag
    }

    @available(*, deprecated, message: "use the =~= operator on `Optional<Resource.Tag>` directly")
    @inlinable public
    func matches(tag other:Tag?) -> Bool 
    {
        self.tag =~= other
    }
    
    @frozen public 
    enum Text:String, RawRepresentable, CustomStringConvertible, Sendable
    {
        case plain          = "text/plain"
        case markdown       = "text/markdown"
        case html           = "text/html"
        case css            = "text/css"
        case javascript     = "text/javascript"
        case json           = "application/json"
        case rss            = "application/rss+xml"
        case svg            = "image/svg+xml"
        
        // does not include charset!
        @inlinable public 
        var description:String 
        {
            self.rawValue
        }
    }
    @frozen public 
    enum Binary:RawRepresentable, CustomStringConvertible, Sendable
    {
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
                if let text:Text = .init(rawValue: other)
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
        var rawValue:String 
        {
            switch self
            {
            case .utf8(encoded: let text): return text.description
            case .woff2:    return "font/woff2"
            case .otf:      return "font/otf"
            case .ttf:      return "font/ttf"
            case .png:      return "image/png"
            case .icon:     return "image/x-icon"
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
}
