@_exported import typealias SystemPackage.FilePath
import SystemPackage 

extension Resource 
{
    public 
    struct WritingError:Error, CustomStringConvertible 
    {
        let path:FilePath
        let wrote:Int, 
            total:Int
        
        @usableFromInline 
        init(wrote:Int, of total:Int, to path:FilePath)
        {
            self.path = path 
            self.wrote = wrote 
            self.total = total
        }
        
        public 
        var description:String 
        {
            "could only write \(self.wrote) byte(s) to file '\(self.path)' (total \(self.total))"
        }
    }
    
    @inlinable public static 
    func file(_version:Version, _ path:FilePath, of subtype:Text) throws -> Self
    {
        .text(try Self.read(String.self, from: path), subtype: subtype, version: _version)
    }
    @inlinable public static 
    func file(_version:Version, _ path:FilePath, of subtype:Binary) throws -> Self
    {
        .binary(try Self.read([UInt8].self, from: path), subtype: subtype, version: _version)
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
        let file:FileDescriptor = try .open(path, .readOnly)
        return try file.closeAfter 
        {
            return try initializer(file, Int.init(try file.seek(offset: 0, from: .end)))
        }
    }
    @inlinable public static 
    func write(_ buffer:UnsafeBufferPointer<UInt8>, to path:FilePath) throws 
    {
        let file:FileDescriptor = try .open(path, .writeOnly, options: [.create, .truncate])
        let count:Int = try file.closeAfter 
        {
            try file.write(UnsafeRawBufferPointer.init(buffer))
        }
        guard count == buffer.count
        else
        {
            throw WritingError.init(wrote: count, of: buffer.count, to: path)
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
    /* static 
    func make(directories:[String]) 
    {
        // scan directory paths 
        var path:String = ""
        for next:String in directories where !next.isEmpty
        {
            path += "\(next)/"
            mkdir(path, 0o0755)
        }
    } */
}
