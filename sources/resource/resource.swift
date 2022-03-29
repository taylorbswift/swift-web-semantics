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

extension Resource.Version 
{
    @inlinable public static 
    func * (lhs:Self, rhs:Self) -> Self 
    {
        .init("\(lhs):\(rhs)")
    }
    @inlinable public static 
    func *= (lhs:inout Self, rhs:Self)
    {
        lhs.description.append(contentsOf: ":\(rhs)")
    }
    
    @inlinable public static 
    func * (lhs:Self?, rhs:Self) -> Self? 
    {
        lhs.map { $0 * rhs }
    }
    @inlinable public static 
    func *= (lhs:inout Self?, rhs:Self)
    {
        lhs?.description.append(contentsOf: ":\(rhs)")
    }
}
extension Optional where Wrapped == Resource.Version
{
    @inlinable public static 
    func * (lhs:Self, rhs:Self) -> Self 
    {
        rhs.flatMap { (rhs:Wrapped) in lhs.map { $0 * rhs } }
    }
    @inlinable public static 
    func *= (lhs:inout Self, rhs:Self)
    {
        rhs.map { lhs?.description.append(contentsOf: ":\($0)") }
    }
}

@frozen public 
enum Resource:Sendable 
{
    @frozen public 
    struct Version:Hashable, CustomStringConvertible, Sendable  
    {
        /* @frozen public 
        struct Semantic:Hashable, Comparable, CustomStringConvertible  
        {
            public 
            var major:Int, 
                minor:Int, 
                patch:Int
                
            @inlinable public 
            var description:String 
            {
                "\(self.major).\(self.minor).\(self.patch)"
            }

            @inlinable public 
            init(_ major:Int, _ minor:Int, _ patch:Int)
            {
                self.major = major
                self.minor = minor
                self.patch = patch
            }
            
            @inlinable public static 
            func < (lhs:Self, rhs:Self) -> Bool 
            {
                (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
            }
        }  */
        
        public
        var description:String 
        
        @inlinable public
        var etag:String 
        {
            """
            "\(self.description)"
            """
        }
        
        @inlinable public static
        func semantic(_ major:Int, _ minor:Int, _ patch:Int) -> Self 
        {
            .init("\(major).\(minor).\(patch)")
        }
        

        
        @inlinable public 
        init(_ description:String)
        {
            self.description = description
        }
        @inlinable public 
        init?(etag:String)
        {
            guard case ("\""?, "\""?) = (etag.first, etag.last)
            else 
            {
                return nil 
            }
            self.description = .init(etag.dropFirst().dropLast())
        }
    }
    
    case text(String,    type:Text = .plain, version:Version? = nil)
    case binary([UInt8], type:Binary,        version:Version? = nil) 
    
    @inlinable public static
    func utf8(encoded bytes:[UInt8], type:Text = .plain, version:Version? = nil) -> Self
    {
        .binary(bytes, type: .utf8(encoded: type), version: version)
    }
    
    @inlinable public
    var version:Version?
    {
        switch self
        {
        case    .text   (_, type: _, version: let version),
                .binary (_, type: _, version: let version):
            return version
        }
    }
    @inlinable public
    func matches(version other:Version?) -> Bool 
    {
        if let other:Version = other, case other? = self.version
        {
            return true 
        }
        else 
        {
            return false 
        }
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
        @inlinable public 
        var description:String 
        {
            self.rawValue 
        }
    }
}
