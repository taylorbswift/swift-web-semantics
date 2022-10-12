#if swift(>=5.5)
extension WebResponse.Redirection:Sendable {}
extension WebResponse.Location:Sendable {}
extension WebResponse:Sendable {}
#endif 

@frozen public 
struct WebResponse:Equatable
{
    @frozen public 
    enum Location:Equatable
    {
        case none 
        case one(String)
        case many 
        case error
    }
    @frozen public
    enum Redirection:Equatable
    {
        case none(Payload)
        case permanent 
        case temporary
    }
    /// The URI associated with this response. This URI is expected to have 
    /// gone through some amount of normalization, and may be slightly 
    /// different from the original request URI. 
    /// 
    /// This URI is not necessarily the same as the canonical URI stored in 
    /// this response’s ``status``.
    public 
    var uri:String 
    /// The plurality of results returned by this response, or an error.
    /// A successful match does not mean this response includes a payload; 
    /// it may return a redirect instead. 
    public 
    var location:Location
    /// The kind of redirect this response returns, or its payload, if no 
    /// redirect will be issued.
    public 
    var redirection:Redirection

    @inlinable public 
    var canonical:String 
    {
        if case .one(let canonical) = self.location
        {
            return canonical 
        }
        else 
        {
            return self.uri
        }
    }

    @inlinable public 
    init(uri:String, location:Location, redirection:Redirection)
    {
        self.uri = uri 
        self.location = location 
        self.redirection = redirection
    }
    @inlinable public 
    init(uri:String, canonical:String, redirection:Redirection)
    {
        self.init(uri: uri, location: .one(canonical), redirection: redirection)
    }
    @inlinable public 
    init(uri:String, location:Location, payload:Payload)
    {
        self.init(uri: uri, location: location, redirection: .none(payload))
    }
    @inlinable public 
    init(uri:String, canonical:String, payload:Payload)
    {
        self.init(uri: uri, canonical: canonical, redirection: .none(payload))
    }
}