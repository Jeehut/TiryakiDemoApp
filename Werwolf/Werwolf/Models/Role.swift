import Foundation

/// Represents different roles in the Werwolf game
/// Each role has specific abilities, team allegiances, and game behaviors
enum Role: String, CaseIterable, Identifiable, Codable {
    case werewolf = "werewolf"
    case seer = "seer"
    case doctor = "doctor"
    case villager = "villager"
    
    // MARK: - Identifiable
    
    var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// Human-readable name for the role
    var displayName: String {
        switch self {
        case .werewolf:
            return "Werewolf"
        case .seer:
            return "Seer"
        case .doctor:
            return "Doctor"
        case .villager:
            return "Villager"
        }
    }
    
    /// Detailed description of role abilities and objectives
    var description: String {
        switch self {
        case .werewolf:
            return "You are a werewolf! Each night, work with other werewolves to eliminate a villager. Your goal is to equal or outnumber the villagers. During the day, blend in and avoid suspicion."
        case .seer:
            return "You are the seer! Each night, you can investigate one player to learn if they are a werewolf. Use this knowledge wisely during day discussions to help the villagers identify threats."
        case .doctor:
            return "You are the doctor! Each night, you can protect one player from werewolf attacks. You cannot protect the same player two nights in a row. Keep the village safe!"
        case .villager:
            return "You are a villager! You have no special abilities, but your vote and voice are crucial. Listen carefully during discussions and help identify the werewolves among you."
        }
    }
    
    /// Brief role summary for quick reference
    var shortDescription: String {
        switch self {
        case .werewolf:
            return "Eliminate villagers at night"
        case .seer:
            return "Investigate players at night"
        case .doctor:
            return "Protect players from attacks"
        case .villager:
            return "Find and eliminate werewolves"
        }
    }
    
    // MARK: - Team Allegiance
    
    /// Team this role belongs to
    var team: Team {
        switch self {
        case .werewolf:
            return .werewolf
        case .seer, .doctor, .villager:
            return .villager
        }
    }
    
    /// Whether this role is on the villager team
    var isVillagerTeam: Bool {
        return team == .villager
    }
    
    // MARK: - Night Actions
    
    /// Whether this role can perform actions during the night phase
    var hasNightAction: Bool {
        switch self {
        case .werewolf, .seer, .doctor:
            return true
        case .villager:
            return false
        }
    }
    
    /// Priority order for night actions (lower numbers go first)
    var nightActionPriority: Int {
        switch self {
        case .seer:
            return 1 // Seer investigates first
        case .werewolf:
            return 2 // Werewolves act second
        case .doctor:
            return 3 // Doctor protects last
        case .villager:
            return 99 // No night action
        }
    }
    
    /// Description of what this role does at night
    var nightActionDescription: String {
        switch self {
        case .werewolf:
            return "Choose a villager to eliminate"
        case .seer:
            return "Choose a player to investigate"
        case .doctor:
            return "Choose a player to protect from attacks"
        case .villager:
            return "No night action available"
        }
    }
    
    /// Device passing instructions for this role's night action
    func devicePassingInstructions() -> String {
        switch self {
        case .werewolf:
            return "Work with other werewolves to choose who to eliminate tonight. Discuss quietly and agree on your target."
        case .seer:
            return "Choose one player to investigate. You will learn if they are a werewolf or not."
        case .doctor:
            return "Choose one player to protect from werewolf attacks tonight. You cannot protect the same player twice in a row."
        case .villager:
            return "You have no night action. Simply confirm and pass the device to the next player."
        }
    }
    
    // MARK: - Special Abilities
    
    /// Whether this role can see other werewolves (werewolf team coordination)
    var canSeeOtherWerewolves: Bool {
        return self == .werewolf
    }
    
    /// Whether this role requires consensus with others of same role
    var requiresConsensus: Bool {
        return self == .werewolf // Werewolves must agree on target
    }
    
    /// Whether this role is immune to night elimination
    var immuneToNightElimination: Bool {
        return false // No roles are inherently immune
    }
    
    // MARK: - Win Conditions
    
    /// Whether this role wins when werewolves equal villagers
    var winsWhenWerewolvesEqual: Bool {
        return team == .werewolf
    }
    
    /// Whether this role wins when no werewolves remain
    var winsWhenNoWerewolves: Bool {
        return team == .villager
    }
    
    // MARK: - Action Validation
    
    /// Checks if this role can target a specific player
    /// - Parameters:
    ///   - targetName: Name of target player
    ///   - availableTargets: List of valid targets
    /// - Returns: True if target is valid for this role
    func canTargetPlayer(_ targetName: String, availableTargets: [String]) -> Bool {
        guard hasNightAction else { return false }
        return availableTargets.contains(targetName)
    }
    
    // MARK: - Role-Specific Methods
    
    /// Gets seer investigation result for a target role
    /// - Parameter targetRole: Role being investigated
    /// - Returns: Investigation result message
    func investigationResult(for targetRole: Role) -> String {
        guard self == .seer else { return "You cannot investigate." }
        
        if targetRole == .werewolf {
            return "This player is a Werewolf!"
        } else {
            return "This player is not a Werewolf."
        }
    }
    
    /// Whether doctor can protect the same player consecutively
    var canProtectSamePlayerConsecutively: Bool {
        return false // Doctor cannot protect same player twice in a row
    }
    
    /// Validates doctor protection based on history
    /// - Parameters:
    ///   - targetName: Player to protect
    ///   - protectionHistory: Recent protection history
    /// - Returns: True if protection is allowed
    func canProtectPlayer(_ targetName: String, given protectionHistory: [String]) -> Bool {
        guard self == .doctor else { return false }
        guard !canProtectSamePlayerConsecutively else { return true }
        
        // Cannot protect same player as last night
        return protectionHistory.last != targetName
    }
    
    // MARK: - Action Timing
    
    /// Type of action this role performs
    var actionTiming: ActionTiming {
        switch self {
        case .seer:
            return .investigation
        case .werewolf:
            return .elimination
        case .doctor:
            return .protection
        case .villager:
            return .none
        }
    }
}

// MARK: - Supporting Types

/// Team allegiances in the game
enum Team: String, CaseIterable, Codable {
    case werewolf = "werewolf"
    case villager = "villager"
    
    var displayName: String {
        switch self {
        case .werewolf:
            return "Werewolves"
        case .villager:
            return "Villagers"
        }
    }
}

/// Types of night actions
enum ActionTiming: String, CaseIterable, Codable {
    case investigation = "investigation"
    case elimination = "elimination"
    case protection = "protection"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .investigation:
            return "Investigation"
        case .elimination:
            return "Elimination"
        case .protection:
            return "Protection"
        case .none:
            return "No Action"
        }
    }
}

// MARK: - Role Distribution Helper

/// Utility for generating and assigning roles
enum RoleDistributor {
    
    /// Generates appropriate roles for given player count
    /// - Parameter playerCount: Number of players in the game
    /// - Returns: Array of roles to assign
    static func generateRoles(for playerCount: Int) -> [Role] {
        guard GameUtilities.isValidPlayerCount(playerCount) else { return [] }
        guard let distribution = GameUtilities.roleDistribution(for: playerCount) else { return [] }
        
        var roles: [Role] = []
        
        // Add werewolves
        for _ in 0..<distribution.werewolves {
            roles.append(.werewolf)
        }
        
        // Add seer
        for _ in 0..<distribution.seer {
            roles.append(.seer)
        }
        
        // Add doctor
        for _ in 0..<distribution.doctor {
            roles.append(.doctor)
        }
        
        // Add villagers
        for _ in 0..<distribution.villagers {
            roles.append(.villager)
        }
        
        return roles
    }
    
    /// Assigns roles randomly to players
    /// - Parameter playerNames: Names of players to assign roles to
    /// - Returns: Dictionary mapping player names to roles
    static func assignRoles(to playerNames: [String]) -> [String: Role] {
        let roles = generateRoles(for: playerNames.count)
        guard roles.count == playerNames.count else { return [:] }
        
        let shuffledRoles = GameUtilities.securelyShuffled(roles)
        var assignments: [String: Role] = [:]
        
        for (index, playerName) in playerNames.enumerated() {
            assignments[playerName] = shuffledRoles[index]
        }
        
        return assignments
    }
}