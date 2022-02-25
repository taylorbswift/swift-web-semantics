import SystemPackage

import func SwiftShell.runAsync 
import class SwiftShell.RunOutput
import class SwiftShell.AsyncCommand

enum Git 
{
    private static 
    func run(_ command:FilePath, _ arguments:[String]) async throws -> String 
    {
        try await withCheckedThrowingContinuation 
        {
            (continuation:CheckedContinuation<String, Error>) in 
            
            runAsync(command.string, arguments).onCompletion 
            {
                (git:AsyncCommand) in 
                do 
                {
                    try git.finish()
                    continuation.resume(returning: git.stdout.read())
                }
                catch let error 
                {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    static 
    func modified(_ path:FilePath, using git:FilePath) async throws -> Bool
    {
        var output:String = try await Self.run(git, ["status", "-s", path.string])
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
    static 
    func lastCommit(_ path:FilePath, using git:FilePath) async throws -> String
    {
        var output:String = try await Self.run(git, ["log", "-n", "1", "--format=%H", path.string])
        while case true? = output.last?.isWhitespace 
        {
            output.removeLast()
        }
        return output
    }
}
