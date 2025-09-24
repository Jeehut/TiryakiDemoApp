import Foundation
import Observation

/// Central game state manager for WerwolfGame
/// Manages all game state with @Observable pattern for SwiftUI integration
/// Handles device passing coordination and privacy-sensitive information filtering
@Observable
final class GameModel {
    
    // MARK: - Public Game State
    
    /// Current list of players in the game
    var players: [Player] = []
    
    /// Current phase of the game
    var currentPhase: GamePhase = .setup
    
    /// Whether the game is currently active
    var isGameActive: Bool = false
    
    /// Index of the current player (for device passing)
    var currentPlayerIndex: Int? = nil
    
    /// Game outcome if game is over
    var gameOutcome: GameOutcome? = nil
    
    // MARK: - Private Game State (@ObservationIgnored for privacy)
    
    /// Private role assignments - not observable to prevent accidental UI exposure
    @ObservationIgnored
    private var roleAssignments: [String: Role] = [:]
    
    /// Private voting records - hidden until voting complete
    @ObservationIgnored
    private var currentVotes: [String: String] = [:] // voter -> voted_for
    
    /// Private night action records
    @ObservationIgnored
    private var nightActions: [String: String] = [:] // actor -> target
    
    /// Private game history for state validation
    @ObservationIgnored
    private var gameHistory: [GameStateSnapshot] = []
    
    /// Start time of current phase (for optional timers)
    @ObservationIgnored
    private var phaseStartTime: Date = Date()
    
    // MARK: - Initialization
    
    init() {
        resetGameState()
    }
    
    // MARK: - Player Management
    
    /// Adds players to the game
    /// - Parameter playerNames: Array of player names to add
    func addPlayers(_ playerNames: [String]) {
        guard currentPhase == .setup else { return }
        
        let trimmedNames = playerNames.map { $0.trimmingCharacters(in: .whitespaces) }
        let uniqueNames = Array(Set(trimmedNames)).filter { !$0.isEmpty }
        
        players = uniqueNames.map { Player(name: $0) }
    }
    
    /// Removes all players and resets game
    func clearPlayers() {
        guard currentPhase == .setup else { return }
        players.removeAll()
        resetGameState()
    }
    
    /// Gets players that are currently alive
    /// - Returns: Array of living players
    func alivePlayers() -> [Player] {
        return players.filter { $0.isAlive }
    }
    
    /// Checks if a specific player is alive
    /// - Parameter playerName: Name of player to check
    /// - Returns: True if player exists and is alive
    func isPlayerAlive(_ playerName: String) -> Bool {
        return players.first { $0.name == playerName }?.isAlive ?? false
    }
    
    // MARK: - Game Flow Control
    
    /// Starts a new game with current players
    /// - Returns: True if game started successfully
    @discardableResult
    func startGame() -> Bool {
        guard GameUtilities.isValidPlayerCount(players.count) else { return false }
        guard currentPhase == .setup else { return false }
        
        // Assign roles randomly
        assignRolesRandomly()
        
        // Initialize game state
        isGameActive = true
        currentPhase = .roleReveal
        currentPlayerIndex = 0
        gameOutcome = nil
        phaseStartTime = Date()
        
        // Record game start
        recordGameStateSnapshot()
        
        return true
    }
    
    /// Advances to the next game phase
    func advanceToNextPhase() {
        guard isGameActive else { return }
        
        switch currentPhase {
        case .setup:
            currentPhase = .roleReveal
            currentPlayerIndex = 0
        case .roleReveal:
            currentPhase = .nightPhase
            setupNightPhase()
        case .nightPhase:
            currentPhase = .dayPhase
            currentPlayerIndex = nil // Group phase
        case .dayPhase:
            currentPhase = .voting
            setupVotingPhase()
        case .voting:
            processVotingResults()
            currentPhase = .elimination
        case .elimination:
            if let outcome = checkGameOutcome() {
                gameOutcome = outcome
                currentPhase = .gameOver
                isGameActive = false
            } else {
                currentPhase = .nightPhase
                setupNightPhase()
            }
        case .gameOver:
            break // Game is over
        }
        
        phaseStartTime = Date()
        recordGameStateSnapshot()
    }
    
    /// Checks current win condition
    /// - Returns: Game outcome if game should end, nil if game continues
    func checkGameOutcome() -> GameOutcome? {
        let alivePlayers = self.alivePlayers()
        let aliveWerewolves = alivePlayers.filter { playerRole(for: $0.name) == .werewolf }.count
        let aliveVillagers = alivePlayers.filter { playerRole(for: $0.name) != .werewolf }.count
        
        return GameUtilities.checkWinCondition(aliveWerewolves: aliveWerewolves, aliveVillagers: aliveVillagers)
    }
    
    // MARK: - Device Passing Coordination
    
    /// Advances to the next player for device passing
    func advanceCurrentPlayer() {
        guard let currentIndex = currentPlayerIndex else {
            currentPlayerIndex = 0
            return
        }
        
        let alivePlayers = self.alivePlayers()
        guard !alivePlayers.isEmpty else { return }
        
        currentPlayerIndex = (currentIndex + 1) % alivePlayers.count
    }
    
    /// Gets current device passing instructions
    /// - Returns: Instructions for current device holder
    func currentDevicePassingInstructions() -> DevicePassingInstructions {
        guard let currentIndex = currentPlayerIndex else {
            return DevicePassingInstructions(
                who: "Everyone",
                what: "Prepare for next phase",
                when: "When ready, continue to next phase"
            )
        }
        
        let alivePlayers = self.alivePlayers()
        guard currentIndex < alivePlayers.count else {
            return DevicePassingInstructions(who: "Unknown", what: "Error", when: "Contact support")
        }
        
        let currentPlayer = alivePlayers[currentIndex]
        let role = playerRole(for: currentPlayer.name)
        
        switch currentPhase {
        case .roleReveal:
            return DevicePassingInstructions(
                who: currentPlayer.name,
                what: "Look at your secret role. Read it carefully and understand your abilities.",
                when: "After viewing your role, pass device to the next player"
            )
        case .nightPhase:
            if let role = role, role.hasNightAction {
                return DevicePassingInstructions(
                    who: currentPlayer.name,
                    what: role.devicePassingInstructions(),
                    when: "After making your choice, pass device to the next night player"
                )
            } else {
                return DevicePassingInstructions(
                    who: currentPlayer.name,
                    what: "You have no night action. Simply confirm and pass the device.",
                    when: "Immediately pass to next player"
                )
            }
        case .voting:
            return DevicePassingInstructions(
                who: currentPlayer.name,
                what: "Cast your vote privately. Choose who to eliminate.",
                when: "After voting, pass device to next player"
            )
        default:
            return DevicePassingInstructions(
                who: "Everyone",
                what: "Group phase - device stays in center",
                when: "Continue when ready"
            )
        }
    }
    
    // MARK: - Role and Privacy Management
    
    /// Gets a player's role (privacy-controlled)
    /// - Parameter playerName: Name of player
    /// - Returns: Player's role if authorized to view
    func playerRole(for playerName: String) -> Role? {
        return roleAssignments[playerName]
    }
    
    /// Gets role information for players with specific role
    /// - Parameter role: Role to search for
    /// - Returns: Array of players with that role
    func playersWithRole(_ role: Role) -> [Player] {
        return players.filter { playerRole(for: $0.name) == role && $0.isAlive }
    }
    
    /// Gets visible player information (privacy-filtered)
    /// - Parameters:
    ///   - playerName: Player to get info about
    ///   - viewerName: Player requesting the information
    /// - Returns: Privacy-filtered player information
    func visiblePlayerInfo(for playerName: String, viewedBy viewerName: String) -> VisiblePlayerInfo {
        guard let player = players.first(where: { $0.name == playerName }) else {
            return VisiblePlayerInfo(name: playerName, isAlive: false, role: nil)
        }
        
        // Role visibility rules
        let visibleRole: Role? = {
            // Players can see their own role
            if playerName == viewerName {
                return playerRole(for: playerName)
            }
            
            // Werewolves can see other werewolves
            if let viewerRole = playerRole(for: viewerName),
               let targetRole = playerRole(for: playerName),
               viewerRole == .werewolf && targetRole == .werewolf {
                return targetRole
            }
            
            // During role reveal phase, no one sees others' roles
            // During other phases, roles remain hidden except for above exceptions
            return nil
        }()
        
        return VisiblePlayerInfo(
            name: player.name,
            isAlive: player.isAlive,
            role: visibleRole
        )
    }
    
    // MARK: - Voting System
    
    /// Records a player's vote
    /// - Parameters:
    ///   - voterName: Name of player casting vote
    ///   - targetName: Name of player being voted for
    /// - Returns: True if vote recorded successfully
    @discardableResult
    func recordVote(from voterName: String, for targetName: String) -> Bool {
        guard currentPhase == .voting else { return false }
        guard isPlayerAlive(voterName) && isPlayerAlive(targetName) else { return false }
        
        currentVotes[voterName] = targetName
        
        // Update player's vote record
        if let voterIndex = players.firstIndex(where: { $0.name == voterName }) {
            players[voterIndex].castVote(for: targetName)
        }
        
        return true
    }
    
    /// Gets current voting status (privacy-controlled)
    /// - Returns: Visible voting information
    func visibleVoteStatus() -> [String: Bool] {
        guard currentPhase == .voting else { return [:] }
        
        // During voting, only show who has voted (not who they voted for)
        var voteStatus: [String: Bool] = [:]
        for player in alivePlayers() {
            voteStatus[player.name] = currentVotes[player.name] != nil
        }
        return voteStatus
    }
    
    /// Gets final voting results (after voting complete)
    /// - Returns: Vote tallies if voting is finalized
    func votingResults() -> [String: Int]? {
        guard currentPhase == .elimination || currentPhase == .gameOver else { return nil }
        
        var tallies: [String: Int] = [:]
        for (_, votedFor) in currentVotes {
            tallies[votedFor, default: 0] += 1
        }
        return tallies
    }
    
    /// Finalizes current voting round
    func finalizeVoting() {
        guard currentPhase == .voting else { return }
        
        // Process votes will be called in advanceToNextPhase()
    }
    
    // MARK: - Night Actions
    
    /// Records werewolf elimination choice
    /// - Parameter targetName: Player to eliminate
    /// - Returns: True if choice recorded
    @discardableResult
    func recordWerewolfChoice(target targetName: String) -> Bool {
        guard currentPhase == .nightPhase else { return false }
        guard isPlayerAlive(targetName) else { return false }
        
        nightActions["werewolf_target"] = targetName
        return true
    }
    
    /// Records seer investigation choice
    /// - Parameter targetName: Player to investigate
    /// - Returns: True if choice recorded
    @discardableResult
    func recordSeerChoice(target targetName: String) -> Bool {
        guard currentPhase == .nightPhase else { return false }
        guard isPlayerAlive(targetName) else { return false }
        
        nightActions["seer_target"] = targetName
        return true
    }
    
    /// Records doctor protection choice
    /// - Parameter targetName: Player to protect
    /// - Returns: True if choice recorded
    @discardableResult
    func recordDoctorChoice(target targetName: String) -> Bool {
        guard currentPhase == .nightPhase else { return false }
        guard isPlayerAlive(targetName) else { return false }
        
        nightActions["doctor_target"] = targetName
        return true
    }
    
    // MARK: - Player Elimination
    
    /// Eliminates a player from the game
    /// - Parameter playerName: Name of player to eliminate
    /// - Returns: True if elimination successful
    @discardableResult
    func eliminatePlayer(_ playerName: String) -> Bool {
        guard let playerIndex = players.firstIndex(where: { $0.name == playerName }) else { return false }
        guard players[playerIndex].isAlive else { return false }
        
        players[playerIndex].eliminate()
        return true
    }
    
    // MARK: - Private Helper Methods
    
    /// Resets all game state to initial values
    private func resetGameState() {
        currentPhase = .setup
        isGameActive = false
        currentPlayerIndex = nil
        gameOutcome = nil
        roleAssignments.removeAll()
        currentVotes.removeAll()
        nightActions.removeAll()
        gameHistory.removeAll()
        phaseStartTime = Date()
    }
    
    /// Randomly assigns roles to all players
    private func assignRolesRandomly() {
        guard let distribution = GameUtilities.roleDistribution(for: players.count) else { return }
        
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
        
        // Shuffle and assign
        let shuffledRoles = GameUtilities.securelyShuffled(roles)
        
        for (index, player) in players.enumerated() {
            let role = shuffledRoles[index]
            players[index].assignRole(role)
            roleAssignments[player.name] = role
        }
    }
    
    /// Sets up night phase with appropriate player order
    private func setupNightPhase() {
        // Reset night actions
        nightActions.removeAll()
        
        // Set first night actor (typically seer, then werewolves, then doctor)
        let nightActors = alivePlayers().filter { player in
            if let role = playerRole(for: player.name) {
                return role.hasNightAction
            }
            return false
        }.sorted { player1, player2 in
            let role1 = playerRole(for: player1.name)!
            let role2 = playerRole(for: player2.name)!
            return role1.nightActionPriority < role2.nightActionPriority
        }
        
        currentPlayerIndex = nightActors.isEmpty ? nil : 0
    }
    
    /// Sets up voting phase
    private func setupVotingPhase() {
        currentVotes.removeAll()
        currentPlayerIndex = 0
        
        // Clear previous votes on all players
        for index in players.indices {
            players[index].clearVote()
        }
    }
    
    /// Processes voting results and handles elimination
    private func processVotingResults() {
        guard let results = votingResults() else { return }
        
        let votingResult = GameUtilities.processVotes(results)
        
        switch votingResult {
        case .elimination(let playerName):
            eliminatePlayer(playerName)
        case .tie(let candidates):
            // Handle tie - for now, randomly select from tied candidates
            if !candidates.isEmpty {
                let selected = GameUtilities.randomSelection(from: candidates, count: 1).first!
                eliminatePlayer(selected)
            }
        }
    }
    
    /// Records current game state for history
    private func recordGameStateSnapshot() {
        let snapshot = GameStateSnapshot(
            phase: currentPhase,
            alivePlayers: alivePlayers().map { $0.name },
            timestamp: Date()
        )
        gameHistory.append(snapshot)
    }
}

// MARK: - Supporting Types

/// Device passing instructions for coordinated gameplay
struct DevicePassingInstructions {
    let who: String      // WHO should take the device
    let what: String     // WHAT they should do
    let when: String     // WHEN to pass it on
}

/// Privacy-filtered player information for UI display
struct VisiblePlayerInfo {
    let name: String
    let isAlive: Bool
    let role: Role?      // Only visible under specific privacy rules
}

/// Game state snapshot for history tracking
private struct GameStateSnapshot {
    let phase: GamePhase
    let alivePlayers: [String]
    let timestamp: Date
}