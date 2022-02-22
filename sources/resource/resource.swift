@frozen public 
enum Resource 
{
    @frozen public 
    struct Version:Hashable, Comparable, CustomStringConvertible  
    {
        public 
        var major:Int, 
            minor:Int, 
            patch:Int
            
        public 
        var description:String 
        {
            "\(self.major).\(self.minor).\(self.patch)"
        }
        @inlinable public
        var etag:String 
        {
            """
            "\(self.major).\(self.minor).\(self.patch)"
            """
        }
        @inlinable public 
        init(_ major:Int, _ minor:Int, _ patch:Int)
        {
            self.major = major
            self.minor = minor
            self.patch = patch
        }
        @inlinable public 
        init?(etag:String)
        {
            guard case ("\""?, "\""?) = (etag.first, etag.last)
            else 
            {
                return nil 
            }
            let components:[Substring] = etag.dropFirst().dropLast().split(separator: ".")
            guard                components.count == 3, 
                    let patch:Int = .init(components[2]),
                    let minor:Int = .init(components[1]),
                    let major:Int = .init(components[0])
            else 
            {
                return nil 
            }
            self.patch = patch 
            self.minor = minor 
            self.major = major
        }
        
        @inlinable public static 
        func < (lhs:Self, rhs:Self) -> Bool 
        {
            (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
        }
    }
    
    case text(String,    subtype:Text = .plain, version:Version? = nil)
    case binary([UInt8], subtype:Binary,        version:Version? = nil) 
    
    @frozen public 
    enum Text:String, RawRepresentable, CustomStringConvertible
    {
        case plain          = "text/plain"
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
    enum Binary:String, RawRepresentable, CustomStringConvertible
    {
        case otf    = "font/otf"
        case png    = "image/png"
        case icon   = "image/x-icon"
        
        @inlinable public 
        var description:String 
        {
            self.rawValue
        }
    }
    
    @frozen public 
    enum Immediate<Endpoint> 
    {
        case immediate(Resource, error:Int? = nil)
        case redirect(String)
        case dynamic(Endpoint)
    }
    @frozen public 
    enum Dynamic
    {
        case dynamic(Resource, error:Int? = nil)
    }
}
