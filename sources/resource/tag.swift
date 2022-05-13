infix operator =~= :ComparisonPrecedence

extension Resource 
{
    @available(*, deprecated, renamed: "Tag")
    public 
    typealias Version = Tag 
    
    @frozen public 
    struct Tag:Hashable, CustomStringConvertible, ExpressibleByStringLiteral, Sendable  
    {        
        public
        var description:String 
        
        @inlinable public
        var etag:String 
        {
            """
            "\(self.description)"
            """
        }
        
        @available(*, deprecated, message: "use a string literal instead")
        @inlinable public static
        func semantic(_ major:Int, _ minor:Int, _ patch:Int) -> Self 
        {
            .init("\(major).\(minor).\(patch)")
        }
        
        @inlinable public 
        init(stringLiteral:String)
        {
            self.init(stringLiteral)
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
}
extension Resource.Tag 
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
extension Optional where Wrapped == Resource.Tag
{
    @inlinable public static 
    func * (lhs:Self, rhs:Self) -> Self 
    {
        rhs.flatMap { (rhs:Wrapped) in lhs.map { $0 * rhs } }
    }
    @inlinable public static 
    func *= (lhs:inout Self, rhs:Self)
    {
        if let rhs:Wrapped = rhs 
        { 
            lhs?.description.append(contentsOf: ":\(rhs)") 
        }
        else if case _? = lhs
        {
            lhs = nil 
        }
    }
    
    @inlinable public static 
    func =~= (lhs:Self, rhs:Self) -> Bool 
    {
        switch (lhs, rhs)
        {
        case (let lhs?, let rhs?):  return lhs == rhs 
        default:                    return false 
        }
    }
}
