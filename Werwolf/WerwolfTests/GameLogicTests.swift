import Testing
import Foundation
@testable import Werwolf

/// Test suite for game logic engine functionality
/// Validates win condition detection, vote tallying, and tie-breaking procedures
struct GameLogicTests {
    
    // MARK: - Win Condition Tests
    
    @Test("Villagers win when all werewolves eliminated")
    func villagersWinCondition() {
        let gameLogic = GameLogicEngine()
        
        // Setup: 6 players, 2 werewolves, 4 villagers
        let players = createTestPlayers(count: 6, werewolves: 2)
        gameLogic.setupGame(with: players)
        
        // Eliminate all werewolves
        let werewolves = players.filter { $0.role == .werewolf }
        for werewolf in werewolves {
            gameLogic.eliminatePlayer(werewolf.name)
        }
        
        let outcome = gameLogic.checkWinCondition()
        #expect(outcome == .villagersWin, "Villagers should win when all werewolves eliminated")
        #expect(gameLogic.isGameOver, "Game should be over when win condition reached")
    }
    
    @Test("Werewolves win when equal to villagers")
    func werewolvesWinCondition() {
        let gameLogic = GameLogicEngine()
        
        // Setup: 6 players, 2 werewolves, 4 villagers
        let players = createTestPlayers(count: 6, werewolves: 2)
        gameLogic.setupGame(with: players)
        
        // Eliminate villagers until werewolves equal remaining players
        let villagers = players.filter { $0.role != .werewolf }
        let villagersToEliminate = villagers.prefix(2) // Leave 2 villagers, 2 werewolves
        
        for villager in villagersToEliminate {
            gameLogic.eliminatePlayer(villager.name)
        }
        
        let outcome = gameLogic.checkWinCondition()
        #expect(outcome == .werewolvesWin, "Werewolves should win when equal to villagers")
        #expect(gameLogic.isGameOver, "Game should be over when win condition reached")
    }
    
    @Test("No win condition when game should continue")
    func gameCountinues() {
        let gameLogic = GameLogicEngine()
        
        // Setup: 6 players, 2 werewolves, 4 villagers
        let players = createTestPlayers(count: 6, werewolves: 2)
        gameLogic.setupGame(with: players)
        
        // Eliminate one villager - game should continue
        let villagers = players.filter { $0.role != .werewolf }
        gameLogic.eliminatePlayer(villagers[0].name)
        
        let outcome = gameLogic.checkWinCondition()
        #expect(outcome == nil, "Game should continue when no win condition met")
        #expect(!gameLogic.isGameOver, "Game should not be over")
    }
    
    // MARK: - Vote Processing Tests
    
    @Test("Simple majority vote results in elimination")
    func simpleMajorityVote() {
        let gameLogic = GameLogicEngine()
        let votes = [
            "Alice": 3,
            "Bob": 2,
            "Carol": 1
        ]
        
        let result = gameLogic.processVotes(votes)
        
        #expect(result.isElimination, "Result should be elimination")
        #expect(result.eliminatedPlayer == "Alice", "Alice should be eliminated with most votes")
    }
    
    @Test("Tie vote handling")
    func tieVoteHandling() {
        let gameLogic = GameLogicEngine()
        let votes = [
            "Alice": 2,
            "Bob": 2,
            "Carol": 1
        ]
        
        let result = gameLogic.processVotes(votes)
        
        #expect(!result.isElimination, "Result should not be elimination with tie")
        #expect(result.tieCandidates.contains("Alice"), "Alice should be tie candidate")
        #expect(result.tieCandidates.contains("Bob"), "Bob should be tie candidate")
        #expect(!result.tieCandidates.contains("Carol"), "Carol should not be tie candidate")
    }
    
    @Test("Complete tie vote scenario")
    func completeTieVote() {
        let gameLogic = GameLogicEngine()
        let votes = [
            "Alice": 2,
            "Bob": 2,
            "Carol": 2
        ]
        
        let result = gameLogic.processVotes(votes)
        
        #expect(!result.isElimination, "Result should not be elimination with complete tie")
        #expect(result.tieCandidates.count == 3, "All three should be tie candidates")
    }
    
    @Test("No votes scenario")
    func noVotesScenario() {
        let gameLogic = GameLogicEngine()
        let votes: [String: Int] = [:]
        
        let result = gameLogic.processVotes(votes)
        
        #expect(!result.isElimination, "No elimination with no votes")
        #expect(result.tieCandidates.isEmpty, "No tie candidates with no votes")
    }
    
    // MARK: - Tie Breaking Tests
    
    @Test("Random tie breaking selection")
    func randomTieBreaking() {
        let gameLogic = GameLogicEngine()
        let tieCandidates = ["Alice", "Bob", "Carol"]
        
        // Run tie breaking multiple times to verify randomness
        var selections: Set<String> = []
        for _ in 0..<10 {
            let selected = gameLogic.breakTieRandomly(among: tieCandidates)
            selections.insert(selected)
        }
        
        #expect(!selections.isEmpty, "Should select at least one candidate")
        #expect(selections.isSubset(of: Set(tieCandidates)), "All selections should be from candidates")
    }
    
    @Test("Tie breaking with single candidate")
    func tieBrakingWithSingleCandidate() {
        let gameLogic = GameLogicEngine()
        let tieCandidates = ["Alice"]
        
        let selected = gameLogic.breakTieRandomly(among: tieCandidates)
        #expect(selected == "Alice", "Should select the only candidate")
    }
    
    // MARK: - Role Balance Validation Tests
    
    @Test("Role assignment balance validation")
    func roleAssignmentBalanceValidation() {
        let gameLogic = GameLogicEngine()
        
        // Test various player counts
        let testCounts = [4, 6, 8, 10]
        
        for count in testCounts {
            let isBalanced = gameLogic.validateRoleBalance(playerCount: count)
            #expect(isBalanced, "Role balance should be valid for \(count) players")
            
            let distribution = gameLogic.calculateRoleDistribution(for: count)
            let totalRoles = distribution.werewolves + distribution.seer + distribution.doctor + distribution.villagers
            #expect(totalRoles == count, "Total roles should equal player count for \(count) players")
        }
    }
    
    @Test("Invalid player count balance validation")
    func invalidPlayerCountBalance() {
        let gameLogic = GameLogicEngine()
        
        // Too few players
        let tooFewBalance = gameLogic.validateRoleBalance(playerCount: 2)
        #expect(!tooFewBalance, "Should not be balanced with too few players")
        
        // Too many players
        let tooManyBalance = gameLogic.validateRoleBalance(playerCount: 15)
        #expect(!tooManyBalance, "Should not be balanced with too many players")
    }
    
    // MARK: - Game State Progression Tests
    
    @Test("Night phase elimination processing")
    func nightPhaseEliminationProcessing() {
        let gameLogic = GameLogicEngine()
        let players = createTestPlayers(count: 6, werewolves: 2)
        gameLogic.setupGame(with: players)
        
        // Werewolves choose victim
        let victim = players.first { $0.role != .werewolf }!
        gameLogic.recordWerewolfChoice(target: victim.name)
        
        // Doctor may protect (test both scenarios)
        let protectedPlayer = players.first { $0.role == .doctor }!
        gameLogic.recordDoctorChoice(target: protectedPlayer.name)
        
        // Process night phase
        let nightResult = gameLogic.processNightPhase()
        
        // If victim was protected, should be alive; otherwise eliminated
        if victim.name == protectedPlayer.name {
            #expect(nightResult.survivedAttack, "Protected player should survive attack")
            #expect(nightResult.eliminatedPlayer == nil, "No one should be eliminated if protected")
        } else {
            #expect(!nightResult.survivedAttack, "Unprotected player should not survive")
            #expect(nightResult.eliminatedPlayer == victim.name, "Victim should be eliminated")
        }
    }
    
    @Test("Seer investigation processing")
    func seerInvestigationProcessing() {
        let gameLogic = GameLogicEngine()
        let players = createTestPlayers(count: 6, werewolves: 2)
        gameLogic.setupGame(with: players)
        
        let werewolf = players.first { $0.role == .werewolf }!
        let villager = players.first { $0.role == .villager }!
        
        // Seer investigates werewolf
        gameLogic.recordSeerChoice(target: werewolf.name)
        let werewolfResult = gameLogic.processSeerInvestigation()
        #expect(werewolfResult.isWerewolf, "Seer should detect werewolf correctly")
        #expect(werewolfResult.targetName == werewolf.name, "Target should be recorded correctly")
        
        // Seer investigates villager
        gameLogic.recordSeerChoice(target: villager.name)
        let villagerResult = gameLogic.processSeerInvestigation()
        #expect(!villagerResult.isWerewolf, "Seer should detect villager correctly")
        #expect(villagerResult.targetName == villager.name, "Target should be recorded correctly")
    }
    
    // MARK: - Edge Case Tests
    
    @Test("All players vote for same person")
    func allPlayersVoteForSame() {
        let gameLogic = GameLogicEngine()
        let votes = ["Alice": 6] // Everyone votes for Alice
        
        let result = gameLogic.processVotes(votes)
        
        #expect(result.isElimination, "Should be elimination with unanimous vote")
        #expect(result.eliminatedPlayer == "Alice", "Alice should be eliminated")
    }
    
    @Test("Player votes for themselves")
    func playerVotesForSelf() {
        let gameLogic = GameLogicEngine()
        let votes = [
            "Alice": 2, // Alice gets 2 votes including her own
            "Bob": 1
        ]
        
        let result = gameLogic.processVotes(votes)
        
        #expect(result.isElimination, "Self-vote should count normally")
        #expect(result.eliminatedPlayer == "Alice", "Alice should be eliminated despite self-vote")
    }
    
    @Test("Single player game state")
    func singlePlayerGameState() {
        let gameLogic = GameLogicEngine()
        let singlePlayer = [createTestPlayer(name: "Alice", role: .villager)]
        
        gameLogic.setupGame(with: singlePlayer)
        let outcome = gameLogic.checkWinCondition()
        
        // Single player scenarios should be handled gracefully
        #expect(outcome != nil, "Single player game should have defined outcome")
    }
    
    // MARK: - Performance and Stress Tests
    
    @Test("Large vote processing performance")
    func largeVoteProcessingPerformance() {
        let gameLogic = GameLogicEngine()
        
        // Create votes for maximum player count
        var votes: [String: Int] = [:]
        for i in 1...12 {
            votes["Player\(i)"] = Int.random(in: 0...5)
        }
        
        let startTime = Date()
        let result = gameLogic.processVotes(votes)
        let endTime = Date()
        
        let processingTime = endTime.timeIntervalSince(startTime)
        #expect(processingTime < 0.1, "Vote processing should be fast even with max players")
        #expect(result != nil, "Should produce valid result")
    }
}

// MARK: - Helper Functions

extension GameLogicTests {
    
    /// Creates test players with specified counts and roles
    private func createTestPlayers(count: Int, werewolves: Int) -> [Player] {
        var players: [Player] = []
        
        // Add werewolves
        for i in 0..<werewolves {
            var player = Player(name: "Werewolf\(i + 1)")
            player.assignRole(.werewolf)
            players.append(player)
        }
        
        // Add one seer
        if count > werewolves {
            var seer = Player(name: "Seer")
            seer.assignRole(.seer)
            players.append(seer)
        }
        
        // Add one doctor if room
        if count > werewolves + 1 {
            var doctor = Player(name: "Doctor")
            doctor.assignRole(.doctor)
            players.append(doctor)
        }
        
        // Fill remaining with villagers
        let remainingCount = count - players.count
        for i in 0..<remainingCount {
            var villager = Player(name: "Villager\(i + 1)")
            villager.assignRole(.villager)
            players.append(villager)
        }
        
        return players
    }
    
    /// Creates a single test player with specified name and role
    private func createTestPlayer(name: String, role: Role) -> Player {
        var player = Player(name: name)
        player.assignRole(role)
        return player
    }
}