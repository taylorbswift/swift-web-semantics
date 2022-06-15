@_exported @preconcurrency import SystemPackage 
@_exported import Resource

public 
struct VersionController:Sendable 
{
    private 
    let git:FilePath
    public
    let repository:FilePath
    
    public
    init(git:FilePath = "/usr/bin/git", repository:FilePath)
    {
        self.git    = git
        self.repository = repository
    }
    
    // convenience APIs for reading unversioned data relative to repository root 
    public 
    func read(_:String.Type = String.self, from path:FilePath) throws -> String
    {
        try File.read(String.self, from: path.isAbsolute ? path : self.repository.appending(path.components))
    }
    public 
    func read(_:[UInt8].Type = [UInt8].self, from path:FilePath) throws -> [UInt8]
    {
        try File.read([UInt8].self, from: path.isAbsolute ? path : self.repository.appending(path.components))
    }
    
    public
    func read(concatenating head:FilePath, _ body:FilePath..., type:Resource.Text) async throws -> Resource
    {
        guard head.isRelative 
        else 
        {
            fatalError("path is not relative")
        }
        async let tag:Resource.Tag? = self.revision(of: head)
        var bytes:[UInt8] = try File.read([UInt8].self, from: self.repository.appending(head.components))
        var hash:Resource.Tag? = try await tag
        
        for next:FilePath in body 
        {
            guard next.isRelative 
            else 
            {
                fatalError("path is not relative")
            }
            async let tag:Resource.Tag? = self.revision(of: next)
            bytes += try File.read([UInt8].self, from: self.repository.appending(next.components))
            hash  *= try await tag
        }
                
        return .utf8(encoded: bytes, type: type, tag: hash)
    }
    public
    func read(from path:FilePath, type:Resource.Text) async throws -> Resource
    {
        try await self.read(concatenating: path, type: type)
    }
    public
    func read(from path:FilePath, type:Resource.Binary) async throws -> Resource
    {
        guard path.isRelative 
        else 
        {
            fatalError("path is not relative")
        }
        async let tag:Resource.Tag? = self.revision(of: path)
        let bytes:[UInt8]                   = try File.read([UInt8].self, from: self.repository.appending(path.components))
        return .binary(bytes, type: type, tag: try await tag)
    }

    private 
    func modified(_ path:FilePath) async throws -> Bool
    {
        var output:String = try await Self.run(self.git, ["-C", self.repository.string, "status", "-s", path.string])
        while let last:Character = output.last
        {
            guard last.isWhitespace 
            else 
            {
                return true
            }
            output.removeLast()
        }
        return false 
    }
    private 
    func lastCommit(_ path:FilePath) async throws -> String
    {
        var output:String = try await Self.run(self.git, ["-C", self.repository.string, "log", "-n", "1", "--format=%H", path.string])
        while case true? = output.last?.isWhitespace 
        {
            output.removeLast()
        }
        return output
    }
    
    public 
    func revision(of path:FilePath) async throws -> Resource.Tag?
    {
        async let commit:String = self.lastCommit(path)        
        if try await self.modified(path)
        {
            return nil
        }
        return .init(try await commit)
    }
}
