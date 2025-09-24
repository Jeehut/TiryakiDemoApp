import Testing
import Foundation
@testable import Werwolf

/// Test suite for GameModel core state management
/// Validates @Observable state changes, device passing coordination, and privacy boundaries
struct GameModelTests {
    
    // MARK: - Game Initialization Tests
    
    @Test("GameModel initializes with empty state")
    func gameModelInitialization() {
        let gameModel = GameModel()
        
        #expect(gameModel.players.isEmpty, "Initial players list should be empty")
        #expect(gameModel.currentPhase == .setup, "Initial phase should be setup")
        #expect(!gameModel.isGameActive, "Game should not be active initially")
        #expect(gameModel.currentPlayerIndex == nil, "No current player initially")
    }
    
    @Test("GameModel player management")
    func playerManagement() {
        let gameModel = GameModel()
        let playerNames = ["Alice", "Bob", "Carol", "David"]
        
        // Test adding players
        gameModel.addPlayers(playerNames)
        #expect(gameModel.players.count == 4, "Should have 4 players after adding")
        #expect(gameModel.players.map(\.name) == playerNames, "Player names should match input")
        
        // Test clearing players
        gameModel.clearPlayers()
        #expect(gameModel.players.isEmpty, "Players should be empty after clearing")
    }
    
    // MARK: - Game State Transition Tests
    
    @Test("Game phase transitions follow correct sequence")
    func gamePhaseTransitions() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        
        // Start game
        gameModel.startGame()
        #expect(gameModel.currentPhase == .roleReveal, "Should transition to role reveal after start")
        #expect(gameModel.isGameActive, "Game should be active after start")
        
        // Test phase progression
        gameModel.advanceToNextPhase()
        #expect(gameModel.currentPhase == .nightPhase, "Should advance to night phase")
        
        gameModel.advanceToNextPhase()
        #expect(gameModel.currentPhase == .dayPhase, "Should advance to day phase")
        
        gameModel.advanceToNextPhase()
        #expect(gameModel.currentPhase == .voting, "Should advance to voting phase")
    }
    
    @Test("Game state validation prevents invalid transitions")
    func invalidStateTransitions() {
        let gameModel = GameModel()
        
        // Cannot start game without sufficient players
        gameModel.startGame()
        #expect(!gameModel.isGameActive, "Game should not start without players")
        #expect(gameModel.currentPhase == .setup, "Should remain in setup phase")
        
        // Add insufficient players
        gameModel.addPlayers(["Alice", "Bob"])
        gameModel.startGame()
        #expect(!gameModel.isGameActive, "Game should not start with insufficient players")
    }
    
    // MARK: - Device Passing Coordination Tests
    
    @Test("Device passing coordination tracks current player")
    func devicePassingCoordination() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        gameModel.startGame()
        
        // Test role reveal device passing
        gameModel.currentPhase = .roleReveal
        #expect(gameModel.currentPlayerIndex == 0, "Should start with first player")
        
        gameModel.advanceCurrentPlayer()
        #expect(gameModel.currentPlayerIndex == 1, "Should advance to second player")
        
        gameModel.advanceCurrentPlayer()
        #expect(gameModel.currentPlayerIndex == 2, "Should advance to third player")
        
        // Test wrapping to first player
        gameModel.advanceCurrentPlayer()
        gameModel.advanceCurrentPlayer()
        #expect(gameModel.currentPlayerIndex == 0, "Should wrap to first player")
    }
    
    @Test("Device passing instructions generated correctly")
    func devicePassingInstructions() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol"])
        gameModel.startGame()
        
        // Test role reveal instructions
        gameModel.currentPhase = .roleReveal
        gameModel.currentPlayerIndex = 0
        let instructions = gameModel.currentDevicePassingInstructions()
        
        #expect(instructions.who == "Alice", "Instructions should identify correct player")
        #expect(instructions.what.contains("role"), "Instructions should mention role reveal")
        #expect(instructions.when.contains("after"), "Instructions should provide return timing")
    }
    
    // MARK: - Privacy Boundary Tests
    
    @Test("Private information properly filtered")
    func privacyFiltering() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        gameModel.startGame()
        
        // Test role privacy - other players should not see roles
        let aliceRole = gameModel.playerRole(for: "Alice")
        let aliceVisibleToOthers = gameModel.visiblePlayerInfo(for: "Alice", viewedBy: "Bob")
        
        #expect(aliceRole != nil, "Alice should have a role assigned")
        #expect(aliceVisibleToOthers.role == nil, "Role should not be visible to other players")
        #expect(aliceVisibleToOthers.name == "Alice", "Name should be visible")
        #expect(aliceVisibleToOthers.isAlive, "Alive status should be visible")
    }
    
    @Test("Voting privacy maintained")
    func votingPrivacy() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        gameModel.startGame()
        gameModel.currentPhase = .voting
        
        // Test private voting
        gameModel.recordVote(from: "Alice", for: "Bob")
        gameModel.recordVote(from: "Bob", for: "Carol")
        
        // Votes should not be visible until voting complete
        let currentVotes = gameModel.visibleVoteStatus()
        #expect(currentVotes.isEmpty, "Votes should not be visible during voting")
        
        // Complete voting round
        gameModel.recordVote(from: "Carol", for: "Bob")
        gameModel.recordVote(from: "David", for: "Bob")
        gameModel.finalizeVoting()
        
        let finalResults = gameModel.votingResults()
        #expect(finalResults != nil, "Voting results should be available after finalization")
    }
    
    // MARK: - Observable State Change Tests
    
    @Test("Observable state changes trigger correctly")
    func observableStateChanges() {
        let gameModel = GameModel()
        
        // Monitor state changes using @Observable
        var phaseChangeDetected = false
        
        // This would normally be done through SwiftUI's observation system
        // For testing, we verify state changes are properly marked
        let initialPhase = gameModel.currentPhase
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        gameModel.startGame()
        
        #expect(gameModel.currentPhase != initialPhase, "Phase should change after starting game")
        #expect(gameModel.isGameActive, "Game active state should change")
    }
    
    @Test("Player state changes reflected correctly")
    func playerStateChanges() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        gameModel.startGame()
        
        // Test player elimination
        let initialAliveCount = gameModel.alivePlayers().count
        gameModel.eliminatePlayer("Alice")
        
        #expect(gameModel.alivePlayers().count == initialAliveCount - 1, "Alive player count should decrease")
        #expect(!gameModel.isPlayerAlive("Alice"), "Alice should not be alive after elimination")
        #expect(gameModel.isPlayerAlive("Bob"), "Other players should remain alive")
    }
    
    // MARK: - Win Condition Tests
    
    @Test("Win condition detection works correctly")
    func winConditionDetection() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        gameModel.startGame()
        
        // Simulate werewolf elimination scenario
        // This would require knowing role assignments, simplified for test
        let werewolves = gameModel.playersWithRole(.werewolf)
        
        // Eliminate all werewolves
        for werewolf in werewolves {
            gameModel.eliminatePlayer(werewolf.name)
        }
        
        let outcome = gameModel.checkGameOutcome()
        #expect(outcome == .villagersWin, "Villagers should win when all werewolves eliminated")
        #expect(!gameModel.isGameActive, "Game should end when win condition reached")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Error handling for invalid operations")
    func errorHandling() {
        let gameModel = GameModel()
        
        // Test operations on non-existent players
        let result = gameModel.eliminatePlayer("NonExistentPlayer")
        #expect(!result, "Should fail to eliminate non-existent player")
        
        // Test invalid vote recording
        gameModel.addPlayers(["Alice", "Bob"])
        gameModel.startGame()
        let voteResult = gameModel.recordVote(from: "Charlie", for: "Alice")
        #expect(!voteResult, "Should fail to record vote from non-existent player")
    }
}

// MARK: - Helper Extensions for Testing

extension GameModelTests {
    
    /// Creates a standard test game setup
    private func createTestGame(playerCount: Int = 6) -> GameModel {
        let gameModel = GameModel()
        let names = ["Alice", "Bob", "Carol", "David", "Eve", "Frank"].prefix(playerCount)
        gameModel.addPlayers(Array(names))
        gameModel.startGame()
        return gameModel
    }
}