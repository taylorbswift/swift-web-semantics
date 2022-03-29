@_exported @preconcurrency import struct SystemPackage.FilePath
import SystemPackage 
import Resource

public 
struct Bureaucrat:Sendable 
{
    public 
    struct FileError:Error, CustomStringConvertible 
    {
        let path:FilePath
        let error:Error 
        
        @usableFromInline 
        init(path:FilePath, error:Error)
        {
            self.path   = path 
            self.error  = error
        }
        
        public 
        var description:String 
        {
            "\(self.error) (path: \(self.path))"
        }
    }
    
    private 
    let git:FilePath, 
        repository:FilePath
    
    public
    init(git:FilePath = "/usr/bin/git", repository:FilePath)
    {
        self.git        = git
        self.repository = repository
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
    func version(of path:FilePath) async throws -> Resource.Version?
    {
        async let commit:String = self.lastCommit(path)
        if try await self.modified(path)
        {
            return nil
        }
        return .init(try await commit)
    }
    
    public
    func read(concatenating head:FilePath, _ body:FilePath..., type:Resource.Text) async throws -> Resource
    {
        guard head.isRelative 
        else 
        {
            fatalError("path is not relative")
        }
        async let version:Resource.Version? = self.version(of: head)
        var bytes:[UInt8]           = try Self.read([UInt8].self, from: self.repository.appending(head.components))
        var hash:Resource.Version?  = try await version
        
        for next:FilePath in body 
        {
            guard next.isRelative 
            else 
            {
                fatalError("path is not relative")
            }
            async let version:Resource.Version? = self.version(of: head)
            bytes += try Self.read([UInt8].self, from: self.repository.appending(next.components))
            hash  *= try await version
        }
        return .utf8(encoded: bytes, type: type, version: hash)
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
        async let version:Resource.Version? = self.version(of: path)
        let bytes:[UInt8]                   = try Self.read([UInt8].self, from: self.repository.appending(path.components))
        return .binary(bytes, type: type, version: try await version)
    }
    
    @inlinable public static 
    func read(_:[UInt8].Type = [UInt8].self, from path:FilePath) throws -> [UInt8]
    {
        try Self.read(from: path)
        {
            (file:FileDescriptor, count:Int) in 
            try .init(unsafeUninitializedCapacity: count)
            {
                $1 = try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
            }
        }
    }
    @inlinable public static 
    func read(_:String.Type = String.self, from path:FilePath) throws -> String
    {
        try Self.read(from: path)
        {
            (file:FileDescriptor, count:Int) in 
            try .init(unsafeUninitializedCapacity: count)
            {
                try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
            }
        }
    }
    @inlinable public static 
    func read<T>(from path:FilePath, _ initializer:(FileDescriptor, Int) throws -> T) throws -> T
    {
        do 
        {
            let file:FileDescriptor = try .open(path, .readOnly)
            return try file.closeAfter 
            {
                return try initializer(file, Int.init(try file.seek(offset: 0, from: .end)))
            }
        }
        catch let error 
        {
            throw FileError.init(path: path, error: error)
        }
    }
    
    public 
    struct IncompleteWriteError:Error, CustomStringConvertible 
    {
        let wrote:Int, 
            total:Int
        
        @usableFromInline 
        init(wrote:Int, of total:Int)
        {
            self.wrote = wrote 
            self.total = total
        }
        
        public 
        var description:String 
        {
            "could only write \(self.wrote) of \(self.total) byte(s)"
        }
    }
    
    @inlinable public static 
    func write(_ buffer:UnsafeBufferPointer<UInt8>, to path:FilePath) throws 
    {
        do 
        {
            let file:FileDescriptor = try .open(path, .writeOnly, 
                options:        [.create, .truncate], 
                permissions:    [.ownerReadWrite, .groupRead, .otherRead])
            let count:Int           = try file.closeAfter 
            {
                try file.write(UnsafeRawBufferPointer.init(buffer))
            }
            guard count == buffer.count
            else
            {
                throw IncompleteWriteError.init(wrote: count, of: buffer.count)
            }
        }
        catch let error 
        {
            throw FileError.init(path: path, error: error)
        }
    }
    @inlinable public static 
    func write(_ array:[UInt8], to path:FilePath) throws
    {
        try array.withUnsafeBufferPointer { try Self.write($0, to: path) }
    }
    @inlinable public static 
    func write(_ string:String, to path:FilePath) throws
    {
        var string:String = string 
        try string.withUTF8 { try Self.write($0, to: path) }
    }
    // will make the string UTF-8 and contiguous 
    @inlinable public static 
    func write(_ string:inout String, to path:FilePath) throws
    {
        try string.withUTF8 { try Self.write($0, to: path) }
    }
}
