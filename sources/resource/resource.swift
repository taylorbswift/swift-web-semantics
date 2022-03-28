public 
protocol ServiceBackend 
{
    associatedtype Endpoint
    associatedtype Continuation where Continuation:Sendable
    
    func request(uri:String) -> DynamicResponse<Endpoint>
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
        
        @inlinable public static 
        func * (lhs:Self, rhs:Self) -> Self 
        {
            .init("\(lhs):\(rhs)")
        }
        @inlinable public static 
        func *= (lhs:inout Self, rhs:Self)
        {
            lhs.description += ":\(rhs)"
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
    case bytes([UInt8],  type:Text,          version:Version? = nil)
    case binary([UInt8], type:Binary,        version:Version? = nil) 
    
    @inlinable public
    var version:Version?
    {
        switch self
        {
        case    .text   (_, type: _, version: let version),
                .bytes  (_, type: _, version: let version),
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
    enum Binary:String, RawRepresentable, CustomStringConvertible, Sendable
    {
        case woff2  = "font/woff2"
        case otf    = "font/otf"
        case ttf    = "font/ttf"
        case png    = "image/png"
        case icon   = "image/x-icon"
        
        @inlinable public 
        var description:String 
        {
            self.rawValue
        }
    }
}
