@frozen public 
enum Resource 
{
    @frozen public 
    struct Version:Hashable  
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
        var key:String 
        
        @inlinable public
        var etag:String 
        {
            """
            "\(self.key)"
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
            lhs.key += ":\(rhs)"
        }
        
        @inlinable public 
        init(_ key:String)
        {
            self.key = key
        }
        @inlinable public 
        init?(etag:String)
        {
            guard case ("\""?, "\""?) = (etag.first, etag.last)
            else 
            {
                return nil 
            }
            self.key = .init(etag.dropFirst().dropLast())
        }
    }
    
    case text(String,    type:Text = .plain, version:Version? = nil)
    case bytes([UInt8],  type:Text,          version:Version? = nil)
    case binary([UInt8], type:Binary,        version:Version? = nil) 
    
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
