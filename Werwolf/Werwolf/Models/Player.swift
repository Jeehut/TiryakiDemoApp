import Foundation

/// Represents a player in the Werwolf game
/// Manages player state, role assignment, and voting behavior
struct Player: Identifiable, Hashable, Codable {
    
    // MARK: - Identity
    
    let id = UUID()
    let name: String
    
    // MARK: - Game State
    
    /// Whether the player is currently alive
    private(set) var isAlive: Bool = true
    
    /// Player's assigned role (nil until roles are assigned)
    private(set) var role: Role?
    
    /// Current vote target (nil if not voted or vote cleared)
    private(set) var votedFor: String?
    
    /// Reason for elimination (if eliminated)
    private(set) var eliminationReason: EliminationReason?
    
    /// When the player was eliminated (if eliminated)
    private(set) var eliminationTime: Date?
    
    // MARK: - Initialization
    
    /// Creates a new player with the given name
    /// - Parameter name: Player's display name (will be trimmed)
    init(name: String) {
        self.name = name.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Role Management
    
    /// Assigns a role to this player
    /// - Parameter role: The role to assign
    mutating func assignRole(_ role: Role) {
        self.role = role
    }
    
    /// Checks if player has a specific role
    /// - Parameter role: Role to check for
    /// - Returns: True if player has the specified role
    func hasRole(_ role: Role) -> Bool {
        return self.role == role
    }
    
    /// Whether this player can perform night actions
    var canPerformNightAction: Bool {
        guard let role = role else { return false }
        return isAlive && role.hasNightAction
    }
    
    /// Whether this player is on the werewolf team
    var isWerewolf: Bool {
        return role?.team == .werewolf
    }
    
    /// Whether this player is on the villager team
    var isVillager: Bool {
        return role?.isVillagerTeam == true
    }
    
    // MARK: - Voting
    
    /// Casts a vote for another player
    /// - Parameter targetName: Name of player to vote for
    mutating func castVote(for targetName: String) {
        guard isAlive else { return }
        votedFor = targetName
    }
    
    /// Clears the current vote
    mutating func clearVote() {
        votedFor = nil
    }
    
    /// Whether this player has voted in the current round
    var hasVoted: Bool {
        return votedFor != nil
    }
    
    // MARK: - Elimination
    
    /// Eliminates this player from the game
    /// - Parameter reason: Reason for elimination
    mutating func eliminate(reason: EliminationReason = .unknown) {
        guard isAlive else { return }
        
        isAlive = false
        eliminationReason = reason
        eliminationTime = Date()
        clearVote() // Clear any pending vote
    }
    
    /// Revives this player (primarily for testing/debugging)
    mutating func revive() {
        isAlive = true
        eliminationReason = nil
        eliminationTime = nil
    }
    
    // MARK: - Hashable & Identifiable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case name, isAlive, role, votedFor, eliminationReason, eliminationTime
    }
}

// MARK: - Elimination Reasons

/// Reasons why a player might be eliminated
enum EliminationReason: String, CaseIterable, Codable {
    case werewolfKill = "werewolf_kill"
    case voting = "voting"
    case unknown = "unknown"
    
    /// Human-readable description
    var description: String {
        switch self {
        case .werewolfKill:
            return "Eliminated by werewolves during the night"
        case .voting:
            return "Eliminated by village vote during the day"
        case .unknown:
            return "Eliminated for unknown reason"
        }
    }
    
    /// Short description for UI
    var shortDescription: String {
        switch self {
        case .werewolfKill:
            return "Night kill"
        case .voting:
            return "Voted out"
        case .unknown:
            return "Eliminated"
        }
    }
}