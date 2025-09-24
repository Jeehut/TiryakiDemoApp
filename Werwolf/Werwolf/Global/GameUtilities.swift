import Foundation

/// Utility functions for WerwolfGame logic and operations
enum GameUtilities {
    
    // MARK: - Role Balance Calculation
    
    /// Calculates the optimal role distribution for a given player count
    /// - Parameter playerCount: Number of players in the game
    /// - Returns: Role distribution tuple or nil if player count is invalid
    static func roleDistribution(for playerCount: Int) -> (werewolves: Int, seer: Int, doctor: Int, villagers: Int)? {
        guard let distribution = GameConstants.roleDistribution.first(where: { $0.playerCount == playerCount }) else {
            return nil
        }
        
        return (
            werewolves: distribution.werewolves,
            seer: distribution.seer,
            doctor: distribution.doctor,
            villagers: distribution.villagers
        )
    }
    
    /// Validates if a player count is within acceptable game limits
    /// - Parameter playerCount: Number of players to validate
    /// - Returns: True if player count is valid for gameplay
    static func isValidPlayerCount(_ playerCount: Int) -> Bool {
        return playerCount >= GameConstants.minimumPlayerCount && 
               playerCount <= GameConstants.maximumPlayerCount
    }
    
    /// Calculates the minimum number of werewolves needed to maintain game balance
    /// - Parameter playerCount: Total number of players
    /// - Returns: Minimum werewolf count or nil if invalid player count
    static func minimumWerewolfCount(for playerCount: Int) -> Int? {
        guard isValidPlayerCount(playerCount) else { return nil }
        
        // Generally 25-33% of players should be werewolves for balance
        return max(1, playerCount / 4)
    }
    
    // MARK: - Game State Validation
    
    /// Checks if the game has reached a win condition
    /// - Parameters:
    ///   - aliveWerewolves: Number of living werewolves
    ///   - aliveVillagers: Number of living villagers (including special roles)
    /// - Returns: Game outcome if game is over, nil if game continues
    static func checkWinCondition(aliveWerewolves: Int, aliveVillagers: Int) -> GameOutcome? {
        if aliveWerewolves == 0 {
            return .villagersWin
        } else if aliveWerewolves >= aliveVillagers {
            return .werewolvesWin
        }
        return nil
    }
    
    // MARK: - Vote Processing
    
    /// Processes voting results and determines elimination
    /// - Parameter votes: Dictionary mapping voted player to number of votes
    /// - Returns: Result of voting (elimination or tie)
    static func processVotes(_ votes: [String: Int]) -> VotingResult {
        guard !votes.isEmpty else {
            return .tie(candidates: [])
        }
        
        let maxVotes = votes.values.max() ?? 0
        let topCandidates = votes.filter { $0.value == maxVotes }.map { $0.key }
        
        if topCandidates.count == 1 {
            return .elimination(player: topCandidates[0])
        } else {
            return .tie(candidates: topCandidates)
        }
    }
    
    // MARK: - Random Utilities
    
    /// Shuffles an array using secure random number generation
    /// - Parameter array: Array to shuffle
    /// - Returns: New shuffled array
    static func securelyShuffled<T>(_ array: [T]) -> [T] {
        var shuffled = array
        
        for i in shuffled.indices.dropLast() {
            let randomIndex = Int.random(in: (i + 1)..<shuffled.count)
            shuffled.swapAt(i, randomIndex)
        }
        
        return shuffled
    }
    
    /// Generates a random selection from an array
    /// - Parameters:
    ///   - array: Source array
    ///   - count: Number of elements to select
    /// - Returns: Array of randomly selected elements
    static func randomSelection<T>(from array: [T], count: Int) -> [T] {
        let shuffled = securelyShuffled(array)
        return Array(shuffled.prefix(count))
    }
    
    // MARK: - Time Utilities
    
    /// Formats a time interval for display
    /// - Parameter timeInterval: Time in seconds
    /// - Returns: Formatted string (e.g., "2:30")
    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Calculates remaining time for a phase
    /// - Parameters:
    ///   - startTime: When the phase started
    ///   - duration: Total duration for the phase
    /// - Returns: Remaining time in seconds, or nil if time has expired
    static func remainingTime(startTime: Date, duration: TimeInterval) -> TimeInterval? {
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = duration - elapsed
        return remaining > 0 ? remaining : nil
    }
}

// MARK: - Supporting Types

/// Possible game outcomes
enum GameOutcome: String, CaseIterable {
    case villagersWin = "villagers_win"
    case werewolvesWin = "werewolves_win"
    
    var displayName: String {
        switch self {
        case .villagersWin:
            return "Villagers Win!"
        case .werewolvesWin:
            return "Werewolves Win!"
        }
    }
    
    var description: String {
        switch self {
        case .villagersWin:
            return "All werewolves have been eliminated. The village is safe!"
        case .werewolvesWin:
            return "The werewolves equal or outnumber the villagers. The village has fallen!"
        }
    }
}

/// Results of a voting round
enum VotingResult {
    case elimination(player: String)
    case tie(candidates: [String])
    
    var isElimination: Bool {
        if case .elimination = self { return true }
        return false
    }
    
    var eliminatedPlayer: String? {
        if case let .elimination(player) = self { return player }
        return nil
    }
    
    var tieCandidates: [String] {
        if case let .tie(candidates) = self { return candidates }
        return []
    }
}