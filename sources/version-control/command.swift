@preconcurrency
import SystemPackage
import SwiftShell

extension VersionController
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
