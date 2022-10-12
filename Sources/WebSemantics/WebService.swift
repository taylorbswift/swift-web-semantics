@_exported import WebResponse

public
protocol WebService<Request>:Sendable
{
    associatedtype Request:Sendable

    func serve(_ request:Request) async throws -> WebResponse
}