import Foundation

/// Extended GamePhase implementation with additional functionality
/// Builds upon the basic enum defined in GameConstants.swift
extension GamePhase {
    
    // MARK: - Phase Flow Management
    
    /// Next phase in the typical game sequence
    var nextPhase: GamePhase? {
        switch self {
        case .setup:
            return .roleReveal
        case .roleReveal:
            return .nightPhase
        case .nightPhase:
            return .dayPhase
        case .dayPhase:
            return .voting
        case .voting:
            return .elimination
        case .elimination:
            return nil // Next phase depends on win condition check
        case .gameOver:
            return nil // Game is finished
        }
    }
    
    /// Whether this phase can transition to another specific phase
    /// - Parameter targetPhase: Phase to transition to
    /// - Returns: True if transition is valid
    func canTransitionTo(_ targetPhase: GamePhase) -> Bool {
        switch (self, targetPhase) {
        case (.setup, .roleReveal):
            return true
        case (.roleReveal, .nightPhase):
            return true
        case (.nightPhase, .dayPhase):
            return true
        case (.dayPhase, .voting):
            return true
        case (.voting, .elimination):
            return true
        case (.elimination, .nightPhase):
            return true // Game continues
        case (.elimination, .gameOver):
            return true // Win condition reached
        case (_, .setup):
            return false // Cannot return to setup except via reset
        default:
            return false
        }
    }
    
    // MARK: - UI and Display Properties
    
    /// Color associated with this phase for UI theming
    var themeColor: String {
        switch self {
        case .setup:
            return "blue"
        case .roleReveal:
            return "purple"
        case .nightPhase:
            return "dark"
        case .dayPhase:
            return "yellow"
        case .voting:
            return "orange"
        case .elimination:
            return "red"
        case .gameOver:
            return "green"
        }
    }
    
    /// Icon name for this phase
    var iconName: String {
        switch self {
        case .setup:
            return "person.3.sequence"
        case .roleReveal:
            return "eye.circle"
        case .nightPhase:
            return "moon.circle"
        case .dayPhase:
            return "sun.max.circle"
        case .voting:
            return "hand.raised.circle"
        case .elimination:
            return "xmark.circle"
        case .gameOver:
            return "flag.checkered.circle"
        }
    }
    
    /// Detailed instructions for this phase
    var instructions: String {
        switch self {
        case .setup:
            return "Enter player names and prepare to start the game. Make sure everyone understands the rules."
        case .roleReveal:
            return "Each player will privately see their role. Pass the device around so everyone can view their secret role."
        case .nightPhase:
            return "Close your eyes! Players with night actions will take turns using the device privately."
        case .dayPhase:
            return "Open your eyes and discuss. Talk about what happened during the night and share suspicions."
        case .voting:
            return "Time to vote! Each player will privately cast their vote to eliminate someone."
        case .elimination:
            return "The votes have been tallied. See who has been eliminated from the village."
        case .gameOver:
            return "The game is over! See which team has won and view the final results."
        }
    }
    
    /// Background music or sound theme for this phase
    var soundTheme: String {
        switch self {
        case .setup:
            return "welcome"
        case .roleReveal:
            return "mysterious"
        case .nightPhase:
            return "dark_ambient"
        case .dayPhase:
            return "village_ambience"
        case .voting:
            return "tension"
        case .elimination:
            return "dramatic"
        case .gameOver:
            return "conclusion"
        }
    }
    
    // MARK: - Timing and Duration
    
    /// Suggested duration for this phase (if using timers)
    var suggestedDuration: TimeInterval {
        switch self {
        case .setup:
            return 0 // No time limit for setup
        case .roleReveal:
            return 30 // 30 seconds per player to view role
        case .nightPhase:
            return GameConstants.nightPhaseTimeLimit
        case .dayPhase:
            return GameConstants.discussionPhaseTimeLimit
        case .voting:
            return GameConstants.votingPhaseTimeLimit
        case .elimination:
            return GameConstants.eliminationDisplayDuration
        case .gameOver:
            return GameConstants.gameOverDisplayDuration
        }
    }
    
    /// Whether this phase should use a timer
    var usesTimer: Bool {
        switch self {
        case .setup, .elimination, .gameOver:
            return false
        case .roleReveal, .nightPhase, .dayPhase, .voting:
            return true
        }
    }
    
    // MARK: - Device Passing Behavior
    
    /// Detailed device passing behavior for this phase
    var devicePassingBehavior: DevicePassingBehavior {
        switch self {
        case .setup:
            return .groupShared(reason: "Everyone participates in game setup")
        case .roleReveal:
            return .sequential(reason: "Each player views their secret role privately")
        case .nightPhase:
            return .conditional(reason: "Only players with night actions take the device")
        case .dayPhase:
            return .groupShared(reason: "Open discussion phase for all players")
        case .voting:
            return .sequential(reason: "Each player casts their vote privately")
        case .elimination:
            return .groupShared(reason: "Results are announced to everyone")
        case .gameOver:
            return .groupShared(reason: "Final results displayed to all players")
        }
    }
    
    /// Instructions for device handling during this phase
    var deviceInstructions: String {
        switch self {
        case .setup, .dayPhase, .elimination, .gameOver:
            return "Device stays in the center where everyone can see."
        case .roleReveal:
            return "Pass device to each player in turn to view their role privately."
        case .nightPhase:
            return "Device is passed only to players who can take night actions."
        case .voting:
            return "Pass device to each living player to cast their vote privately."
        }
    }
    
    // MARK: - Privacy and Security
    
    /// Privacy level required for this phase
    var privacyLevel: PrivacyLevel {
        switch self {
        case .setup, .dayPhase, .elimination, .gameOver:
            return .publicInfo
        case .roleReveal, .nightPhase, .voting:
            return .privateInfo
        }
    }
    
    /// What information should be hidden during this phase
    var hiddenInformation: [HiddenInfoType] {
        switch self {
        case .setup:
            return []
        case .roleReveal:
            return [.otherPlayerRoles]
        case .nightPhase:
            return [.otherPlayerRoles, .nightActions]
        case .dayPhase:
            return [.otherPlayerRoles, .currentVotes]
        case .voting:
            return [.otherPlayerRoles, .currentVotes]
        case .elimination:
            return [.otherPlayerRoles]
        case .gameOver:
            return [] // All information revealed
        }
    }
    
    // MARK: - Validation and Requirements
    
    /// Validates if game can enter this phase
    /// - Parameter gameState: Current game state to validate
    /// - Returns: True if phase transition is valid
    func validateTransition(from gameState: GameStateValidation) -> Bool {
        switch self {
        case .setup:
            return true
        case .roleReveal:
            return gameState.hasMinimumPlayers && gameState.allPlayersHaveNames
        case .nightPhase:
            return gameState.hasLivingPlayers && gameState.rolesAssigned
        case .dayPhase:
            return gameState.hasLivingPlayers
        case .voting:
            return gameState.hasMultipleLivingPlayers
        case .elimination:
            return gameState.votingComplete
        case .gameOver:
            return gameState.winConditionMet
        }
    }
    
    /// Required player states for this phase
    var requiredPlayerStates: [PlayerStateRequirement] {
        switch self {
        case .setup:
            return []
        case .roleReveal:
            return [.hasRole]
        case .nightPhase:
            return [.isAlive, .hasRole]
        case .dayPhase:
            return [.isAlive]
        case .voting:
            return [.isAlive, .canVote]
        case .elimination:
            return []
        case .gameOver:
            return []
        }
    }
}

// MARK: - Supporting Types for GamePhase

/// Device passing behavior patterns
enum DevicePassingBehavior {
    case groupShared(reason: String)        // Device stays in center
    case sequential(reason: String)         // Passed to each player in order
    case conditional(reason: String)        // Passed only to specific players
    
    var isPrivate: Bool {
        switch self {
        case .groupShared:
            return false
        case .sequential, .conditional:
            return true
        }
    }
}

/// Privacy levels for game phases
enum PrivacyLevel: String, CaseIterable {
    case publicInfo = "public"          // All information visible
    case privateInfo = "private"        // Some information hidden
    case secret = "secret"          // Maximum privacy required
    
    var displayName: String {
        switch self {
        case .publicInfo:
            return "Public"
        case .privateInfo:
            return "Private"
        case .secret:
            return "Secret"
        }
    }
}

/// Types of information that can be hidden
enum HiddenInfoType: String, CaseIterable {
    case otherPlayerRoles = "other_player_roles"
    case nightActions = "night_actions"
    case currentVotes = "current_votes"
    case gameHistory = "game_history"
    
    var description: String {
        switch self {
        case .otherPlayerRoles:
            return "Other players' roles"
        case .nightActions:
            return "Night action choices"
        case .currentVotes:
            return "Current vote tallies"
        case .gameHistory:
            return "Previous game events"
        }
    }
}

/// Game state validation requirements
struct GameStateValidation {
    let hasMinimumPlayers: Bool
    let hasMultipleLivingPlayers: Bool
    let hasLivingPlayers: Bool
    let allPlayersHaveNames: Bool
    let rolesAssigned: Bool
    let votingComplete: Bool
    let winConditionMet: Bool
}

/// Player state requirements for phases
enum PlayerStateRequirement: String, CaseIterable {
    case hasRole = "has_role"
    case isAlive = "is_alive"
    case canVote = "can_vote"
    case hasNightAction = "has_night_action"
    
    var description: String {
        switch self {
        case .hasRole:
            return "Player must have an assigned role"
        case .isAlive:
            return "Player must be alive"
        case .canVote:
            return "Player must be able to vote"
        case .hasNightAction:
            return "Player must have a night action"
        }
    }
}