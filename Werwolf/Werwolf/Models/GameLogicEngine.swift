import Foundation

/// Game logic engine for WerwolfGame
/// Handles role assignment balancing, win condition checking, vote processing with tie-breaking
/// Provides centralized game rule validation and state transitions
final class GameLogicEngine {
    
    // MARK: - Game State
    
    private var players: [Player] = []
    private var isGameActive: Bool = false
    private var currentPhase: GamePhase = .setup
    
    // MARK: - Night Action Tracking
    
    private var werewolfTarget: String?
    private var seerTarget: String?
    private var doctorTarget: String?
    private var lastDoctorTarget: String? // For consecutive protection rule
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Game Setup and Management
    
    /// Sets up a new game with the given players
    /// - Parameter players: Array of players to include in the game
    func setupGame(with players: [Player]) {
        self.players = players
        self.isGameActive = !players.isEmpty
        self.currentPhase = .setup
        resetNightActions()
    }
    
    /// Whether the game is currently over
    var isGameOver: Bool {
        return !isGameActive || currentPhase == .gameOver
    }
    
    // MARK: - Win Condition Checking
    
    /// Checks current win condition based on alive players
    /// - Returns: Game outcome if win condition is met, nil otherwise
    func checkWinCondition() -> GameOutcome? {
        let alivePlayers = players.filter { $0.isAlive }
        let aliveWerewolves = alivePlayers.filter { $0.role == .werewolf }.count
        let aliveVillagers = alivePlayers.filter { $0.role != .werewolf }.count
        
        return GameUtilities.checkWinCondition(
            aliveWerewolves: aliveWerewolves, 
            aliveVillagers: aliveVillagers
        )
    }
    
    // MARK: - Vote Processing
    
    /// Processes vote tallies and determines elimination result
    /// - Parameter votes: Dictionary of player names to vote counts
    /// - Returns: Voting result indicating elimination or tie
    func processVotes(_ votes: [String: Int]) -> VotingResult {
        return GameUtilities.processVotes(votes)
    }
    
    /// Breaks ties randomly among tied candidates
    /// - Parameter candidates: Array of tied candidate names
    /// - Returns: Randomly selected candidate for elimination
    func breakTieRandomly(among candidates: [String]) -> String {
        guard !candidates.isEmpty else { return "" }
        return GameUtilities.randomSelection(from: candidates, count: 1)[0]
    }
    
    // MARK: - Player Elimination
    
    /// Eliminates a player from the game
    /// - Parameter playerName: Name of player to eliminate
    /// - Returns: True if elimination was successful
    @discardableResult
    func eliminatePlayer(_ playerName: String) -> Bool {
        guard let playerIndex = players.firstIndex(where: { $0.name == playerName }) else {
            return false
        }
        guard players[playerIndex].isAlive else { return false }
        
        players[playerIndex].eliminate(reason: determineEliminationReason())
        
        // Check if game should end
        if let _ = checkWinCondition() {
            isGameActive = false
            currentPhase = .gameOver
        }
        
        return true
    }
    
    // MARK: - Role Balance Validation
    
    /// Validates if role distribution is balanced for given player count
    /// - Parameter playerCount: Number of players
    /// - Returns: True if roles can be balanced
    func validateRoleBalance(playerCount: Int) -> Bool {
        return GameUtilities.isValidPlayerCount(playerCount) &&
               GameUtilities.roleDistribution(for: playerCount) != nil
    }
    
    /// Calculates role distribution for a specific player count
    /// - Parameter playerCount: Number of players
    /// - Returns: Role distribution tuple
    func calculateRoleDistribution(for playerCount: Int) -> (werewolves: Int, seer: Int, doctor: Int, villagers: Int) {
        return GameUtilities.roleDistribution(for: playerCount) ?? (0, 0, 0, 0)
    }
    
    // MARK: - Night Phase Processing
    
    /// Records werewolf elimination choice
    /// - Parameter targetName: Name of player to eliminate
    func recordWerewolfChoice(target targetName: String) {
        werewolfTarget = targetName
    }
    
    /// Records seer investigation choice
    /// - Parameter targetName: Name of player to investigate
    func recordSeerChoice(target targetName: String) {
        seerTarget = targetName
    }
    
    /// Records doctor protection choice  
    /// - Parameter targetName: Name of player to protect
    func recordDoctorChoice(target targetName: String) {
        doctorTarget = targetName
    }
    
    /// Processes all night actions and returns results
    /// - Returns: Night phase results
    func processNightPhase() -> NightPhaseResult {
        var eliminatedPlayer: String?
        var survivedAttack = false
        var seerResult: SeerResult?
        
        // Process seer investigation first
        if let seerTarget = seerTarget {
            if let targetPlayer = players.first(where: { $0.name == seerTarget }),
               let targetRole = targetPlayer.role {
                seerResult = SeerResult(
                    targetName: seerTarget,
                    isWerewolf: targetRole == .werewolf
                )
            }
        }
        
        // Process werewolf elimination
        if let werewolfTarget = werewolfTarget {
            // Check if target is protected by doctor
            let isProtected = (doctorTarget == werewolfTarget)
            
            if isProtected {
                survivedAttack = true
            } else {
                eliminatedPlayer = werewolfTarget
                eliminatePlayer(werewolfTarget)
            }
        }
        
        // Update doctor protection history
        lastDoctorTarget = doctorTarget
        
        // Reset night actions for next night
        resetNightActions()
        
        return NightPhaseResult(
            eliminatedPlayer: eliminatedPlayer,
            survivedAttack: survivedAttack,
            seerResult: seerResult
        )
    }
    
    /// Processes seer investigation independently
    /// - Returns: Seer investigation result
    func processSeerInvestigation() -> SeerResult {
        guard let seerTarget = seerTarget else {
            return SeerResult(targetName: "", isWerewolf: false)
        }
        
        if let targetPlayer = players.first(where: { $0.name == seerTarget }),
           let targetRole = targetPlayer.role {
            return SeerResult(
                targetName: seerTarget,
                isWerewolf: targetRole == .werewolf
            )
        }
        
        return SeerResult(targetName: seerTarget, isWerewolf: false)
    }
    
    // MARK: - Rule Validation
    
    /// Validates if doctor can protect a specific player
    /// - Parameter targetName: Name of player to protect
    /// - Returns: True if protection is allowed
    func canDoctorProtectPlayer(_ targetName: String) -> Bool {
        // Doctor cannot protect same player two nights in a row
        return lastDoctorTarget != targetName
    }
    
    /// Validates if a player can be targeted for elimination
    /// - Parameter targetName: Name of potential target
    /// - Returns: True if player can be eliminated
    func canTargetPlayerForElimination(_ targetName: String) -> Bool {
        return players.contains { $0.name == targetName && $0.isAlive }
    }
    
    /// Validates if enough players remain to continue game
    /// - Returns: True if game can continue
    func canGameContinue() -> Bool {
        let alivePlayers = players.filter { $0.isAlive }
        return alivePlayers.count >= 3 && checkWinCondition() == nil
    }
    
    // MARK: - Advanced Game Logic
    
    /// Calculates optimal voting strategy for AI assistance (if needed)
    /// - Parameter suspicionLevels: Player suspicion ratings
    /// - Returns: Recommended voting target
    func calculateOptimalVote(suspicionLevels: [String: Double]) -> String? {
        let alivePlayers = players.filter { $0.isAlive }
        let alivePlayerNames = Set(alivePlayers.map { $0.name })
        
        // Find player with highest suspicion who is still alive
        let sortedBySuspicion = suspicionLevels
            .filter { alivePlayerNames.contains($0.key) }
            .sorted { $0.value > $1.value }
        
        return sortedBySuspicion.first?.key
    }
    
    /// Simulates game outcome probabilities
    /// - Returns: Win probability for each team
    func calculateWinProbabilities() -> TeamWinProbabilities {
        let alivePlayers = players.filter { $0.isAlive }
        let werewolfCount = alivePlayers.filter { $0.role == .werewolf }.count
        let villagerCount = alivePlayers.count - werewolfCount
        
        // Simple probability calculation based on remaining players
        let total = Double(werewolfCount + villagerCount)
        
        if total == 0 {
            return TeamWinProbabilities(werewolves: 0.0, villagers: 0.0)
        }
        
        // Base calculation on villager advantage
        let villagerAdvantage = Double(villagerCount) / total
        
        // Adjust for special roles
        let hasActiveSeer = alivePlayers.contains { $0.role == .seer }
        let hasActiveDoctor = alivePlayers.contains { $0.role == .doctor }
        
        var adjustedVillagerChance = villagerAdvantage
        if hasActiveSeer { adjustedVillagerChance += 0.1 }
        if hasActiveDoctor { adjustedVillagerChance += 0.1 }
        
        let adjustedWerewolfChance = 1.0 - adjustedVillagerChance
        
        return TeamWinProbabilities(
            werewolves: max(0.0, min(1.0, adjustedWerewolfChance)),
            villagers: max(0.0, min(1.0, adjustedVillagerChance))
        )
    }
    
    // MARK: - Private Helper Methods
    
    /// Determines elimination reason based on current phase
    private func determineEliminationReason() -> EliminationReason {
        switch currentPhase {
        case .nightPhase:
            return .werewolfKill
        case .elimination:
            return .voting
        default:
            return .unknown
        }
    }
    
    /// Resets all night action targets
    private func resetNightActions() {
        werewolfTarget = nil
        seerTarget = nil
        doctorTarget = nil
    }
    
    // MARK: - Debug and Testing Support
    
    /// Gets current game state for debugging
    func getDebugGameState() -> DebugGameState {
        return DebugGameState(
            players: players,
            isGameActive: isGameActive,
            currentPhase: currentPhase,
            werewolfTarget: werewolfTarget,
            seerTarget: seerTarget,
            doctorTarget: doctorTarget,
            lastDoctorTarget: lastDoctorTarget
        )
    }
    
    /// Forces game state for testing
    func setTestGameState(players: [Player], phase: GamePhase) {
        self.players = players
        self.currentPhase = phase
        self.isGameActive = true
    }
}

// MARK: - Supporting Types for GameLogicEngine

/// Result of night phase processing
struct NightPhaseResult {
    let eliminatedPlayer: String?
    let survivedAttack: Bool
    let seerResult: SeerResult?
    
    var hasElimination: Bool {
        return eliminatedPlayer != nil
    }
    
    var hasSeerResult: Bool {
        return seerResult != nil
    }
}

/// Result of seer investigation
struct SeerResult {
    let targetName: String
    let isWerewolf: Bool
    
    var resultMessage: String {
        if isWerewolf {
            return "\(targetName) is a Werewolf!"
        } else {
            return "\(targetName) is not a Werewolf."
        }
    }
}

/// Win probability calculations
struct TeamWinProbabilities {
    let werewolves: Double
    let villagers: Double
    
    var description: String {
        return "Werewolves: \(Int(werewolves * 100))%, Villagers: \(Int(villagers * 100))%"
    }
}

/// Debug game state information
struct DebugGameState {
    let players: [Player]
    let isGameActive: Bool
    let currentPhase: GamePhase
    let werewolfTarget: String?
    let seerTarget: String?
    let doctorTarget: String?
    let lastDoctorTarget: String?
    
    var playerCount: Int { players.count }
    var alivePlayerCount: Int { players.filter { $0.isAlive }.count }
    var werewolfCount: Int { players.filter { $0.role == .werewolf && $0.isAlive }.count }
    var villagerCount: Int { alivePlayerCount - werewolfCount }
}
