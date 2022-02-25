import struct SystemPackage.FilePath

import func SwiftShell.runAsync 
import class SwiftShell.RunOutput
import class SwiftShell.AsyncCommand

extension Bureaucrat
{
    static 
    func run(_ command:FilePath, _ arguments:[String]) async throws -> String 
    {
        try await withCheckedThrowingContinuation 
        {
            (continuation:CheckedContinuation<String, Error>) in 
            
            runAsync(command.string, arguments).onCompletion 
            {
                (command:AsyncCommand) in 
                do 
                {
                    try command.finish()
                    continuation.resume(returning: command.stdout.read())
                }
                catch let error 
                {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
