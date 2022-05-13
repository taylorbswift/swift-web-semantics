public 
enum FileError:Error, CustomStringConvertible 
{
    case system               (error:Error, path:FilePath)
    case incompleteRead (bytes:Int, of:Int, path:FilePath)
    case incompleteWrite(bytes:Int, of:Int, path:FilePath)
    
    var path:FilePath 
    {
        switch self 
        {
        case    .system(error: _,                 path: let path),
                .incompleteRead (bytes: _, of: _, path: let path),
                .incompleteWrite(bytes: _, of: _, path: let path):
            return path
        }
    }
    
    public 
    var description:String 
    {
        switch self 
        {
        case .system                    (error: let error,          path: let path):
            return "system error '\(error)' while reading file '\(path)'"
        case .incompleteRead (bytes: let read,    of: let expected, path: let path):
            return "could only read \(read) of \(expected) bytes from file '\(path)'"
        case .incompleteWrite(bytes: let written, of: let expected, path: let path):
            return "could only write \(written) of \(expected) bytes to file '\(path)'"
        }
    }
}

public 
enum File 
{
    @inlinable public static 
    func read(_:[UInt8].Type = [UInt8].self, from path:FilePath) throws -> [UInt8]
    {
        let (count, array):(Int, [UInt8]) = try Self.read(from: path)
        {
            (file:FileDescriptor, count:Int) in 
            (
                count: count, 
                array: try .init(unsafeUninitializedCapacity: count)
                {
                    $1 = try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
                }
            )
        }
        if count != array.count 
        {
            throw FileError.incompleteRead(bytes: array.count, of: count, path: path)
        }
        else 
        {
            return array
        }
    }
    @inlinable public static 
    func read(_:String.Type = String.self, from path:FilePath) throws -> String
    {
        let (count, string):(Int, String) = try Self.read(from: path)
        {
            (file:FileDescriptor, count:Int) in 
            (
                count: count, 
                string: try .init(unsafeUninitializedCapacity: count)
                {
                    try file.read(fromAbsoluteOffset: 0, into: UnsafeMutableRawBufferPointer.init($0))
                }
            )
        }
        if count != string.utf8.count 
        {
            throw FileError.incompleteRead(bytes: string.utf8.count, of: count, path: path)
        }
        else 
        {
            return string
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
            throw FileError.system(error: error, path: path)
        }
    }
    
    @inlinable public static 
    func write(_ buffer:UnsafeBufferPointer<UInt8>, to path:FilePath) throws 
    {
        let count:Int 
        do 
        {
            let file:FileDescriptor = try .open(path, .writeOnly, 
                options:        [.create, .truncate], 
                permissions:    [.ownerReadWrite, .groupRead, .otherRead])
            count = try file.closeAfter 
            {
                try file.write(UnsafeRawBufferPointer.init(buffer))
            }
        }
        catch let error 
        {
            throw FileError.system(error: error, path: path)
        }
        guard count == buffer.count
        else
        {
            throw FileError.incompleteWrite(bytes: count, of: buffer.count, path: path)
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
