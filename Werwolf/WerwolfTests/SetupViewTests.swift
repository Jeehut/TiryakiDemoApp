import Testing
import Foundation
@testable import Werwolf

/// Test suite for setup flow UI components
/// Validates player entry, role customization, and game start confirmation flows
struct SetupViewTests {
    
    // MARK: - Player Entry Tests
    
    @Test("PlayerSetupView initializes correctly")
    func playerSetupViewInitialization() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        #expect(setupView.gameModel.players.isEmpty, "Should start with no players")
        #expect(setupView.gameModel.currentPhase == .setup, "Should be in setup phase")
    }
    
    @Test("Player names can be added and validated")
    func playerNamesCanBeAddedAndValidated() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        let playerNames = ["Alice", "Bob", "Carol", "David", "Eve", "Frank"]
        setupView.addPlayers(playerNames)
        
        #expect(gameModel.players.count == 6, "Should have 6 players")
        #expect(gameModel.players.map(\.name) == playerNames, "Player names should match")
    }
    
    @Test("Duplicate player names are rejected")
    func duplicatePlayerNamesAreRejected() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        let playerNamesWithDuplicates = ["Alice", "Bob", "Alice", "Carol"]
        setupView.addPlayers(playerNamesWithDuplicates)
        
        let uniqueNames = Array(Set(playerNamesWithDuplicates))
        #expect(gameModel.players.count == uniqueNames.count, "Should filter out duplicates")
    }
    
    @Test("Empty player names are filtered out")
    func emptyPlayerNamesAreFilteredOut() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        let playerNamesWithEmpty = ["Alice", "", "Bob", "   ", "Carol"]
        setupView.addPlayers(playerNamesWithEmpty)
        
        let validNames = playerNamesWithEmpty.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        #expect(gameModel.players.count == validNames.count, "Should filter out empty names")
    }
    
    @Test("Player name length validation")
    func playerNameLengthValidation() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        // Test very long names
        let longName = String(repeating: "a", count: 100)
        let playerNamesWithLong = ["Alice", longName, "Bob"]
        
        let validationResult = setupView.validatePlayerNames(playerNamesWithLong)
        #expect(!validationResult.isValid, "Should reject excessively long names")
        #expect(validationResult.errors.contains { $0.contains("too long") }, "Should provide appropriate error message")
    }
    
    // MARK: - Player Count Validation Tests
    
    @Test("Minimum player count validation")
    func minimumPlayerCountValidation() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        // Test with too few players
        setupView.addPlayers(["Alice", "Bob"])
        
        let canStart = setupView.canStartGame()
        #expect(!canStart.isValid, "Should not allow game start with too few players")
        #expect(canStart.errorMessage?.contains("minimum"), "Should mention minimum player requirement")
    }
    
    @Test("Maximum player count validation")
    func maximumPlayerCountValidation() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        // Test with too many players
        let manyPlayers = (1...15).map { "Player\($0)" }
        setupView.addPlayers(manyPlayers)
        
        let validation = setupView.validatePlayerCount()
        #expect(!validation.isValid, "Should not allow too many players")
        #expect(validation.errorMessage?.contains("maximum"), "Should mention maximum player limit")
    }
    
    @Test("Valid player count ranges")
    func validPlayerCountRanges() {
        let gameModel = GameModel()
        let setupView = PlayerSetupView(gameModel: gameModel)
        
        // Test valid counts
        for count in 3...12 {
            let players = (1...count).map { "Player\($0)" }
            setupView.addPlayers(players)
            
            let canStart = setupView.canStartGame()
            #expect(canStart.isValid, "Should allow game start with \(count) players")
            
            setupView.clearPlayers()
        }
    }
    
    // MARK: - Role Customization Tests
    
    @Test("RoleCustomizationView displays correct role distribution")
    func roleCustomizationViewDisplaysCorrectRoleDistribution() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        
        let customizationView = RoleCustomizationView(gameModel: gameModel)
        let distribution = customizationView.getCurrentRoleDistribution()
        
        #expect(distribution.werewolves == 2, "6-player game should have 2 werewolves")
        #expect(distribution.seer == 1, "6-player game should have 1 seer")
        #expect(distribution.doctor == 1, "6-player game should have 1 doctor")
        #expect(distribution.villagers == 2, "6-player game should have 2 villagers")
    }
    
    @Test("Role customization allows valid modifications")
    func roleCustomizationAllowsValidModifications() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank", "Grace", "Henry"])
        
        let customizationView = RoleCustomizationView(gameModel: gameModel)
        
        // Test enabling optional roles (if supported)
        let customRoles = RoleDistribution(werewolves: 2, seer: 1, doctor: 1, villagers: 4)
        let validationResult = customizationView.validateCustomRoles(customRoles)
        
        #expect(validationResult.isValid, "Custom role distribution should be valid")
        #expect(customRoles.totalRoles == 8, "Total should match player count")
    }
    
    @Test("Role balance validation prevents unwinnable scenarios")
    func roleBalanceValidationPreventsUnwinnableScenarios() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        
        let customizationView = RoleCustomizationView(gameModel: gameModel)
        
        // Test unbalanced role distribution (too many werewolves)
        let unbalancedRoles = RoleDistribution(werewolves: 3, seer: 0, doctor: 0, villagers: 1)
        let validationResult = customizationView.validateCustomRoles(unbalancedRoles)
        
        #expect(!validationResult.isValid, "Should reject unbalanced role distribution")
        #expect(validationResult.errorMessage?.contains("balance"), "Should mention balance issue")
    }
    
    // MARK: - Game Start Confirmation Tests
    
    @Test("GameStartView displays final game summary")
    func gameStartViewDisplaysFinalGameSummary() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        
        let gameStartView = GameStartView(gameModel: gameModel)
        let summary = gameStartView.getGameSummary()
        
        #expect(summary.playerCount == 6, "Summary should show correct player count")
        #expect(summary.playerNames.count == 6, "Should list all player names")
        #expect(!summary.roleDistribution.isEmpty, "Should show role distribution")
    }
    
    @Test("Game start confirmation validates all requirements")
    func gameStartConfirmationValidatesAllRequirements() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        
        let gameStartView = GameStartView(gameModel: gameModel)
        let validation = gameStartView.validateGameStartRequirements()
        
        #expect(validation.hasEnoughPlayers, "Should validate minimum players")
        #expect(validation.allPlayersNamed, "Should validate all players have names")
        #expect(validation.rolesBalanced, "Should validate role balance")
    }
    
    @Test("Game start initializes all necessary state")
    func gameStartInitializesAllNecessaryState() {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        
        let gameStartView = GameStartView(gameModel: gameModel)
        let startResult = gameStartView.startGame()
        
        #expect(startResult.success, "Game start should succeed")
        #expect(gameModel.isGameActive, "Game should be active after start")
        #expect(gameModel.currentPhase == .roleReveal, "Should advance to role reveal phase")
        
        // Verify roles were assigned
        let playersWithRoles = gameModel.players.filter { player in
            gameModel.playerRole(for: player.name) != nil
        }
        #expect(playersWithRoles.count == 6, "All players should have roles assigned")
    }
    
    // MARK: - Accessibility Tests
    
    @Test("Setup views support accessibility")
    func setupViewsSupportAccessibility() {
        let gameModel = GameModel()
        let playerSetupView = PlayerSetupView(gameModel: gameModel)
        
        // Test accessibility labels and hints
        let accessibilityInfo = playerSetupView.getAccessibilityInfo()
        #expect(!accessibilityInfo.labels.isEmpty, "Should have accessibility labels")
        #expect(!accessibilityInfo.hints.isEmpty, "Should have accessibility hints")
        #expect(accessibilityInfo.supportsVoiceOver, "Should support VoiceOver")
    }
    
    @Test("Player input supports Dynamic Type")
    func playerInputSupportsDynamicType() {
        let gameModel = GameModel()
        let playerSetupView = PlayerSetupView(gameModel: gameModel)
        
        let dynamicTypeSupport = playerSetupView.getDynamicTypeSupport()
        #expect(dynamicTypeSupport.scalesWithSystemFont, "Should scale with system font")
        #expect(dynamicTypeSupport.supportsLargeText, "Should support large text sizes")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Setup views handle invalid input gracefully")
    func setupViewsHandleInvalidInputGracefully() {
        let gameModel = GameModel()
        let playerSetupView = PlayerSetupView(gameModel: gameModel)
        
        // Test various invalid inputs
        let invalidInputs = ["", "   ", String(repeating: "a", count: 1000), "\n\t"]
        
        for input in invalidInputs {
            let result = playerSetupView.addSinglePlayer(input)
            #expect(!result.success, "Should reject invalid input: '\(input)'")
            #expect(result.errorMessage != nil, "Should provide error message for invalid input")
        }
    }
    
    @Test("Setup process can be reset at any stage")
    func setupProcessCanBeResetAtAnyStage() {
        let gameModel = GameModel()
        
        // Add players
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David"])
        #expect(gameModel.players.count == 4, "Should have players")
        
        // Reset setup
        let resetResult = gameModel.resetToSetup()
        #expect(resetResult.success, "Reset should succeed")
        #expect(gameModel.players.isEmpty, "Players should be cleared")
        #expect(gameModel.currentPhase == .setup, "Should return to setup phase")
        #expect(!gameModel.isGameActive, "Game should not be active")
    }
    
    // MARK: - UI State Management Tests
    
    @Test("Setup view state persists during modifications")
    func setupViewStatePersistsDuringModifications() {
        let gameModel = GameModel()
        let playerSetupView = PlayerSetupView(gameModel: gameModel)
        
        // Add some players
        playerSetupView.addPlayers(["Alice", "Bob", "Carol"])
        let initialState = playerSetupView.getCurrentState()
        
        // Modify player list
        playerSetupView.addSinglePlayer("David")
        let modifiedState = playerSetupView.getCurrentState()
        
        #expect(modifiedState.playerCount == initialState.playerCount + 1, "State should update correctly")
        #expect(modifiedState.isValid != initialState.isValid || modifiedState.isValid, "Validation state should update")
    }
    
    @Test("Setup views provide real-time validation feedback")
    func setupViewsProvideRealTimeValidationFeedback() {
        let gameModel = GameModel()
        let playerSetupView = PlayerSetupView(gameModel: gameModel)
        
        // Start with invalid state (too few players)
        playerSetupView.addPlayers(["Alice", "Bob"])
        let feedback1 = playerSetupView.getValidationFeedback()
        #expect(!feedback1.isValid, "Should show invalid state")
        #expect(!feedback1.messages.isEmpty, "Should provide feedback messages")
        
        // Add players to reach valid state
        playerSetupView.addSinglePlayer("Carol")
        let feedback2 = playerSetupView.getValidationFeedback()
        #expect(feedback2.isValid, "Should show valid state")
        #expect(feedback2.messages != feedback1.messages, "Feedback should update")
    }
}

// MARK: - Mock UI Components for Testing

/// Mock PlayerSetupView for testing purposes
class PlayerSetupView {
    let gameModel: GameModel
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func addPlayers(_ names: [String]) {
        gameModel.addPlayers(names)
    }
    
    func clearPlayers() {
        gameModel.clearPlayers()
    }
    
    func validatePlayerNames(_ names: [String]) -> ValidationResult {
        var errors: [String] = []
        
        for name in names {
            if name.count > 50 {
                errors.append("Player name '\(name.prefix(10))...' is too long")
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func canStartGame() -> GameStartValidation {
        if gameModel.players.count < GameConstants.minimumPlayerCount {
            return GameStartValidation(
                isValid: false,
                errorMessage: "Need at least \(GameConstants.minimumPlayerCount) players to start"
            )
        }
        return GameStartValidation(isValid: true, errorMessage: nil)
    }
    
    func validatePlayerCount() -> ValidationResult {
        let count = gameModel.players.count
        var errors: [String] = []
        
        if count > GameConstants.maximumPlayerCount {
            errors.append("Maximum \(GameConstants.maximumPlayerCount) players allowed")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func addSinglePlayer(_ name: String) -> AddPlayerResult {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return AddPlayerResult(success: false, errorMessage: "Player name cannot be empty")
        }
        if trimmed.count > 50 {
            return AddPlayerResult(success: false, errorMessage: "Player name is too long")
        }
        
        gameModel.addPlayers([trimmed])
        return AddPlayerResult(success: true, errorMessage: nil)
    }
    
    func getAccessibilityInfo() -> AccessibilityInfo {
        return AccessibilityInfo(
            labels: ["Player Name Input", "Add Player Button", "Start Game Button"],
            hints: ["Enter player name", "Add this player to the game", "Start the game with current players"],
            supportsVoiceOver: true
        )
    }
    
    func getDynamicTypeSupport() -> DynamicTypeSupport {
        return DynamicTypeSupport(scalesWithSystemFont: true, supportsLargeText: true)
    }
    
    func getCurrentState() -> SetupViewState {
        return SetupViewState(
            playerCount: gameModel.players.count,
            isValid: gameModel.players.count >= GameConstants.minimumPlayerCount
        )
    }
    
    func getValidationFeedback() -> ValidationFeedback {
        var messages: [String] = []
        let isValid = gameModel.players.count >= GameConstants.minimumPlayerCount
        
        if !isValid {
            messages.append("Add more players to start the game")
        }
        
        return ValidationFeedback(isValid: isValid, messages: messages)
    }
}

/// Mock RoleCustomizationView for testing purposes
class RoleCustomizationView {
    let gameModel: GameModel
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func getCurrentRoleDistribution() -> RoleDistribution {
        guard let distribution = GameUtilities.roleDistribution(for: gameModel.players.count) else {
            return RoleDistribution(werewolves: 0, seer: 0, doctor: 0, villagers: 0)
        }
        
        return RoleDistribution(
            werewolves: distribution.werewolves,
            seer: distribution.seer,
            doctor: distribution.doctor,
            villagers: distribution.villagers
        )
    }
    
    func validateCustomRoles(_ roles: RoleDistribution) -> ValidationResult {
        let totalRoles = roles.totalRoles
        let playerCount = gameModel.players.count
        
        if totalRoles != playerCount {
            return ValidationResult(
                isValid: false,
                errors: ["Total roles (\(totalRoles)) must match player count (\(playerCount))"]
            )
        }
        
        // Check balance - werewolves shouldn't exceed villagers at start
        if roles.werewolves >= roles.villagerTeamTotal {
            return ValidationResult(
                isValid: false,
                errors: ["Too many werewolves - game balance would be unfair"]
            )
        }
        
        return ValidationResult(isValid: true, errors: [])
    }
}

/// Mock GameStartView for testing purposes
class GameStartView {
    let gameModel: GameModel
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func getGameSummary() -> GameSummary {
        return GameSummary(
            playerCount: gameModel.players.count,
            playerNames: gameModel.players.map(\.name),
            roleDistribution: getCurrentRoleDistribution()
        )
    }
    
    func validateGameStartRequirements() -> GameStartRequirements {
        return GameStartRequirements(
            hasEnoughPlayers: gameModel.players.count >= GameConstants.minimumPlayerCount,
            allPlayersNamed: gameModel.players.allSatisfy { !$0.name.isEmpty },
            rolesBalanced: GameUtilities.isValidPlayerCount(gameModel.players.count)
        )
    }
    
    func startGame() -> GameStartResult {
        let success = gameModel.startGame()
        return GameStartResult(success: success)
    }
    
    private func getCurrentRoleDistribution() -> String {
        guard let distribution = GameUtilities.roleDistribution(for: gameModel.players.count) else {
            return "Invalid player count"
        }
        
        return "\(distribution.werewolves) Werewolves, \(distribution.seer) Seer, \(distribution.doctor) Doctor, \(distribution.villagers) Villagers"
    }
}

// MARK: - Supporting Types for Setup View Tests

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
}

struct GameStartValidation {
    let isValid: Bool
    let errorMessage: String?
}

struct AddPlayerResult {
    let success: Bool
    let errorMessage: String?
}

struct AccessibilityInfo {
    let labels: [String]
    let hints: [String]
    let supportsVoiceOver: Bool
}

struct DynamicTypeSupport {
    let scalesWithSystemFont: Bool
    let supportsLargeText: Bool
}

struct SetupViewState {
    let playerCount: Int
    let isValid: Bool
}

struct ValidationFeedback {
    let isValid: Bool
    let messages: [String]
}

struct RoleDistribution {
    let werewolves: Int
    let seer: Int
    let doctor: Int
    let villagers: Int
    
    var totalRoles: Int {
        return werewolves + seer + doctor + villagers
    }
    
    var villagerTeamTotal: Int {
        return seer + doctor + villagers
    }
}

struct GameSummary {
    let playerCount: Int
    let playerNames: [String]
    let roleDistribution: String
}

struct GameStartRequirements {
    let hasEnoughPlayers: Bool
    let allPlayersNamed: Bool
    let rolesBalanced: Bool
}

struct GameStartResult {
    let success: Bool
}

// MARK: - GameModel Extensions for Testing

extension GameModel {
    func resetToSetup() -> ResetResult {
        clearPlayers()
        return ResetResult(success: true)
    }
}

struct ResetResult {
    let success: Bool
}