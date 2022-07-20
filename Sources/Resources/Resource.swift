@_exported import MIME
@_exported import SHA2

#if swift(>=5.5)
extension Resource:Sendable {}
extension Resource.Payload:Sendable {}
#endif 

@frozen public 
struct Resource:Equatable 
{
    @frozen public 
    enum Payload:Equatable
    {
        case text(String, type:MIME.Text)
        case bytes([UInt8], type:MIME) 
    }
    
    public 
    let payload:Payload 
    public 
    let hash:SHA256?
    
    @inlinable public 
    init(hashing string:String, type:MIME.Text = .plain) 
    {
        self.init(.text(string, type: type), hash: .init(hashing: string.utf8))
    }
    @inlinable public 
    init(hashing bytes:[UInt8], type:MIME) 
    {
        self.init(.bytes(bytes, type: type), hash: .init(hashing: bytes))
    }
    
    @inlinable public 
    init(_ string:String, type:MIME.Text = .plain, hash:SHA256? = nil) 
    {
        self.init(.text(string, type: type), hash: hash)
    }
    @inlinable public 
    init(_ bytes:[UInt8], type:MIME, hash:SHA256? = nil) 
    {
        self.init(.bytes(bytes, type: type), hash: hash)
    }
    @inlinable public 
    init(_ payload:Payload, hash:SHA256? = nil) 
    {
        self.payload = payload 
        self.hash = hash
    }
}
