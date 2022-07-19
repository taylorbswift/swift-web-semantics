@frozen public 
enum Canonicity<Location>
{
    case none 
    case one(Location)
    case many 
    case error
}
@frozen public
enum Redirection<Payload>
{
    case none(Payload)
    case permanent 
    case temporary
}
@frozen public 
struct Response<Payload> 
{
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
    var results:Canonicity<String>
    /// The kind of redirect this response returns, or its payload, if no 
    /// redirect will be issued.
    public 
    var redirection:Redirection<Payload>

    @inlinable public 
    var canonical:String 
    {
        if case .one(let canonical) = self.results
        {
            return canonical 
        }
        else 
        {
            return self.uri
        }
    }

    @inlinable public 
    init(uri:String, results:Canonicity<String>, redirection:Redirection<Payload>)
    {
        self.uri = uri 
        self.results = results 
        self.redirection = redirection
    }
    @inlinable public 
    init(uri:String, canonical:String, redirection:Redirection<Payload>)
    {
        self.init(uri: uri, results: .one(canonical), redirection: redirection)
    }
    @inlinable public 
    init(uri:String, results:Canonicity<String>, payload:Payload)
    {
        self.init(uri: uri, results: results, redirection: .none(payload))
    }
    @inlinable public 
    init(uri:String, canonical:String, payload:Payload)
    {
        self.init(uri: uri, canonical: canonical, redirection: .none(payload))
    }
}