import Foundation

/// Core game constants and configuration for WerwolfGame
/// Defines role balance rules, player limits, and game phase configurations
enum GameConstants {
    
    // MARK: - Player Limits
    
    /// Minimum number of players required to start a game
    static let minimumPlayerCount = 3
    
    /// Maximum number of players supported in a game
    static let maximumPlayerCount = 12
    
    // MARK: - Role Balance Rules
    
    /// Role distribution rules based on player count
    /// Each entry defines: (playerCount, werewolvesCount, villagerRoles)
    static let roleDistribution: [(playerCount: Int, werewolves: Int, seer: Int, doctor: Int, villagers: Int)] = [
        // 3 players: 1 werewolf, 1 seer, 1 villager
        (3, 1, 1, 0, 1),
        // 4 players: 1 werewolf, 1 seer, 1 doctor, 1 villager
        (4, 1, 1, 1, 1),
        // 5 players: 1 werewolf, 1 seer, 1 doctor, 2 villagers
        (5, 1, 1, 1, 2),
        // 6 players: 2 werewolves, 1 seer, 1 doctor, 2 villagers
        (6, 2, 1, 1, 2),
        // 7 players: 2 werewolves, 1 seer, 1 doctor, 3 villagers
        (7, 2, 1, 1, 3),
        // 8 players: 2 werewolves, 1 seer, 1 doctor, 4 villagers
        (8, 2, 1, 1, 4),
        // 9 players: 3 werewolves, 1 seer, 1 doctor, 4 villagers
        (9, 3, 1, 1, 4),
        // 10 players: 3 werewolves, 1 seer, 1 doctor, 5 villagers
        (10, 3, 1, 1, 5),
        // 11 players: 3 werewolves, 1 seer, 1 doctor, 6 villagers
        (11, 3, 1, 1, 6),
        // 12 players: 4 werewolves, 1 seer, 1 doctor, 6 villagers
        (12, 4, 1, 1, 6)
    ]
    
    // MARK: - Game Phase Configuration
    
    /// Duration for night phase actions (optional timer)
    static let nightPhaseTimeLimit: TimeInterval = 60.0
    
    /// Duration for voting phase (optional timer)
    static let votingPhaseTimeLimit: TimeInterval = 30.0
    
    /// Duration for discussion phase (optional timer)
    static let discussionPhaseTimeLimit: TimeInterval = 300.0 // 5 minutes
    
    // MARK: - UI Constants
    
    /// Time to display elimination results before continuing
    static let eliminationDisplayDuration: TimeInterval = 3.0
    
    /// Time to display game over results
    static let gameOverDisplayDuration: TimeInterval = 5.0
    
    /// Delay for dramatic effect during reveals
    static let dramaticRevealDelay: TimeInterval = 1.5
    
    // MARK: - Device Passing Configuration
    
    /// Minimum time device should remain with current player
    static let minimumDevicePassTime: TimeInterval = 5.0
    
    /// Maximum time before prompting for device return
    static let maximumDevicePassTime: TimeInterval = 120.0
    
    // MARK: - Privacy Settings
    
    /// Characters to display when masking sensitive information
    static let privacyMask = "••••••"
    
    /// Time to display privacy warning before showing sensitive content
    static let privacyWarningDuration: TimeInterval = 2.0
}

/// Game phase definitions for state management
enum GamePhase: String, CaseIterable, Codable {
    case setup = "setup"
    case roleReveal = "role_reveal"
    case nightPhase = "night_phase"
    case dayPhase = "day_phase"
    case voting = "voting"
    case elimination = "elimination"
    case gameOver = "game_over"
    
    /// Human-readable name for the phase
    var displayName: String {
        switch self {
        case .setup:
            return "Game Setup"
        case .roleReveal:
            return "Role Reveal"
        case .nightPhase:
            return "Night Phase"
        case .dayPhase:
            return "Day Discussion"
        case .voting:
            return "Voting"
        case .elimination:
            return "Elimination"
        case .gameOver:
            return "Game Over"
        }
    }
    
    /// Whether this phase requires device passing to individual players
    var requiresPrivateDevicePass: Bool {
        switch self {
        case .roleReveal, .nightPhase, .voting:
            return true
        case .setup, .dayPhase, .elimination, .gameOver:
            return false
        }
    }
    
    /// Whether this phase is visible to all players simultaneously
    var isGroupPhase: Bool {
        return !requiresPrivateDevicePass
    }
}