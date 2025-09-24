import Testing
import Foundation
@testable import Werwolf

/// Test suite for game flow UI components
/// Validates private role reveals, night actions, voting, and device handoff instructions
struct GameFlowTests {
    
    // MARK: - Role Reveal Phase Tests
    
    @Test("RoleRevealView shows correct role privately")
    func roleRevealViewShowsCorrectRolePrivately() {
        let gameModel = createTestGame()
        let roleRevealView = RoleRevealView(gameModel: gameModel)
        
        // Test that player sees their own role
        roleRevealView.setCurrentViewer("Alice")
        let aliceRoleInfo = roleRevealView.getCurrentPlayerRole()
        
        #expect(aliceRoleInfo != nil, "Alice should see her role")
        #expect(aliceRoleInfo?.displayName != nil, "Role should have display name")
        #expect(aliceRoleInfo?.description != nil, "Role should have description")
    }
    
    @Test("RoleRevealView hides other players' roles")
    func roleRevealViewHidesOtherPlayersRoles() {
        let gameModel = createTestGame()
        let roleRevealView = RoleRevealView(gameModel: gameModel)
        
        roleRevealView.setCurrentViewer("Alice")
        let otherPlayerRoles = roleRevealView.getOtherPlayersInfo()
        
        for playerInfo in otherPlayerRoles {
            #expect(playerInfo.role == nil, "Other players' roles should be hidden")
            #expect(playerInfo.isAlive, "Should still show alive status")
        }
    }
    
    @Test("RoleRevealView provides clear device passing instructions")
    func roleRevealViewProvidesClearDevicePassingInstructions() {
        let gameModel = createTestGame()
        let roleRevealView = RoleRevealView(gameModel: gameModel)
        
        gameModel.currentPlayerIndex = 0 // Alice
        let instructions = roleRevealView.getDevicePassingInstructions()
        
        #expect(instructions.who == "Alice", "Should specify current player")
        #expect(instructions.what.contains("role"), "Instructions should mention role viewing")
        #expect(instructions.when.contains("pass"), "Instructions should mention when to pass device")
    }
    
    // MARK: - Night Phase UI Tests
    
    @Test("NightPhaseView shows appropriate UI for werewolves")
    func nightPhaseViewShowsAppropriateUIForWerewolves() {
        let gameModel = createTestGame()
        let nightPhaseView = NightPhaseView(gameModel: gameModel)
        
        nightPhaseView.setCurrentViewer("Alice") // Assume Alice is werewolf
        guard gameModel.playerRole(for: "Alice") == .werewolf else { return }
        
        let werewolfUI = nightPhaseView.getWerewolfActionUI()
        
        #expect(werewolfUI.canSelectTarget, "Werewolf should be able to select target")
        #expect(!werewolfUI.availableTargets.isEmpty, "Should have available targets")
        #expect(!werewolfUI.availableTargets.contains("Alice"), "Werewolf shouldn't target themselves")
        
        // Check that other werewolves are visible
        let visiblePlayers = nightPhaseView.getVisiblePlayers()
        let otherWerewolves = visiblePlayers.filter { $0.role == .werewolf && $0.name != "Alice" }
        #expect(!otherWerewolves.isEmpty, "Should see other werewolves")
    }
    
    @Test("NightPhaseView shows appropriate UI for seer")
    func nightPhaseViewShowsAppropriateUIForSeer() {
        let gameModel = createTestGame()
        let nightPhaseView = NightPhaseView(gameModel: gameModel)
        
        // Find the seer player
        if let seerPlayer = gameModel.players.first(where: { gameModel.playerRole(for: $0.name) == .seer }) {
            nightPhaseView.setCurrentViewer(seerPlayer.name)
            
            let seerUI = nightPhaseView.getSeerActionUI()
            
            #expect(seerUI.canInvestigate, "Seer should be able to investigate")
            #expect(!seerUI.availableTargets.isEmpty, "Should have investigation targets")
            #expect(!seerUI.availableTargets.contains(seerPlayer.name), "Seer shouldn't investigate themselves")
        }
    }
    
    @Test("NightPhaseView shows appropriate UI for doctor")
    func nightPhaseViewShowsAppropriateUIForDoctor() {
        let gameModel = createTestGame()
        let nightPhaseView = NightPhaseView(gameModel: gameModel)
        
        // Find the doctor player
        if let doctorPlayer = gameModel.players.first(where: { gameModel.playerRole(for: $0.name) == .doctor }) {
            nightPhaseView.setCurrentViewer(doctorPlayer.name)
            
            let doctorUI = nightPhaseView.getDoctorActionUI()
            
            #expect(doctorUI.canProtect, "Doctor should be able to protect")
            #expect(!doctorUI.availableTargets.isEmpty, "Should have protection targets")
            // Doctor can protect themselves
        }
    }
    
    @Test("NightPhaseView shows waiting UI for villagers")
    func nightPhaseViewShowsWaitingUIForVillagers() {
        let gameModel = createTestGame()
        let nightPhaseView = NightPhaseView(gameModel: gameModel)
        
        // Find a villager
        if let villagerPlayer = gameModel.players.first(where: { gameModel.playerRole(for: $0.name) == .villager }) {
            nightPhaseView.setCurrentViewer(villagerPlayer.name)
            
            let villagerUI = nightPhaseView.getVillagerNightUI()
            
            #expect(!villagerUI.hasActions, "Villager should have no night actions")
            #expect(villagerUI.showWaitingMessage, "Should show waiting message")
            #expect(villagerUI.message.contains("close your eyes"), "Should instruct to close eyes")
        }
    }
    
    // MARK: - Day Phase UI Tests
    
    @Test("DayPhaseView enables group discussion")
    func dayPhaseViewEnablesGroupDiscussion() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .dayPhase
        
        let dayPhaseView = DayPhaseView(gameModel: gameModel)
        let discussionUI = dayPhaseView.getDiscussionUI()
        
        #expect(discussionUI.deviceIsShared, "Device should be shared during discussion")
        #expect(discussionUI.allowsOpenTalk, "Should allow open discussion")
        #expect(!discussionUI.showPrivateInfo, "Should not show private information")
    }
    
    @Test("DayPhaseView shows previous night results")
    func dayPhaseViewShowsPreviousNightResults() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .dayPhase
        
        // Simulate night results
        gameModel.eliminatePlayer("Bob") // Simulate elimination
        
        let dayPhaseView = DayPhaseView(gameModel: gameModel)
        let nightResults = dayPhaseView.getNightResults()
        
        #expect(nightResults.hasElimination, "Should show elimination occurred")
        #expect(nightResults.eliminatedPlayer == "Bob", "Should show who was eliminated")
        #expect(!nightResults.showCauseOfDeath, "Should not reveal werewolf involvement")
    }
    
    @Test("DayPhaseView provides discussion timer if enabled")
    func dayPhaseViewProvidesDiscussionTimerIfEnabled() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .dayPhase
        
        let dayPhaseView = DayPhaseView(gameModel: gameModel)
        dayPhaseView.enableTimer(duration: GameConstants.discussionPhaseTimeLimit)
        
        let timerInfo = dayPhaseView.getTimerInfo()
        
        #expect(timerInfo.isEnabled, "Timer should be enabled")
        #expect(timerInfo.duration > 0, "Timer should have positive duration")
    }
    
    // MARK: - Voting Phase UI Tests
    
    @Test("VotingView provides private voting interface")
    func votingViewProvidesPrivateVotingInterface() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .voting
        
        let votingView = VotingView(gameModel: gameModel)
        votingView.setCurrentVoter("Alice")
        
        let votingUI = votingView.getVotingInterface()
        
        #expect(votingUI.isPrivate, "Voting should be private")
        #expect(!votingUI.availableTargets.isEmpty, "Should have voting targets")
        #expect(votingUI.availableTargets.contains("Alice"), "Can vote for self if desired")
        
        // Test vote casting
        let voteResult = votingView.castVote(for: "Carol")
        #expect(voteResult.success, "Vote should be cast successfully")
    }
    
    @Test("VotingView hides vote tallies during voting")
    func votingViewHidesVoteTalliesDuringVoting() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .voting
        
        let votingView = VotingView(gameModel: gameModel)
        
        // Cast some votes
        gameModel.recordVote(from: "Alice", for: "Bob")
        gameModel.recordVote(from: "Carol", for: "Bob")
        
        let voteDisplay = votingView.getVoteDisplay()
        
        #expect(!voteDisplay.showTallies, "Should not show vote tallies during voting")
        #expect(voteDisplay.showVotingStatus, "Should show who has voted")
        
        let votingStatus = voteDisplay.votingStatus
        #expect(votingStatus["Alice"] == true, "Should show Alice has voted")
        #expect(votingStatus["David"] == false, "Should show David hasn't voted")
    }
    
    @Test("VotingView provides clear device handoff instructions")
    func votingViewProvidesClearDeviceHandoffInstructions() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .voting
        gameModel.currentPlayerIndex = 0
        
        let votingView = VotingView(gameModel: gameModel)
        let instructions = votingView.getDeviceHandoffInstructions()
        
        #expect(instructions.who != nil, "Should specify who takes device")
        #expect(instructions.what.contains("vote"), "Should mention voting")
        #expect(instructions.when.contains("next"), "Should mention passing to next player")
    }
    
    // MARK: - Elimination Phase UI Tests
    
    @Test("EliminationView reveals voting results")
    func eliminationViewRevealsVotingResults() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .elimination
        
        // Simulate completed voting
        gameModel.recordVote(from: "Alice", for: "Bob")
        gameModel.recordVote(from: "Carol", for: "Bob")
        gameModel.recordVote(from: "David", for: "Eve")
        gameModel.finalizeVoting()
        
        let eliminationView = EliminationView(gameModel: gameModel)
        let results = eliminationView.getVotingResults()
        
        #expect(results.showVoteTallies, "Should show vote tallies")
        #expect(results.eliminatedPlayer == "Bob", "Should show eliminated player")
        #expect(!results.revealRoles, "Should not reveal roles yet")
    }
    
    @Test("EliminationView provides dramatic reveal")
    func eliminationViewProvidesDramaticReveal() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .elimination
        gameModel.eliminatePlayer("Bob")
        
        let eliminationView = EliminationView(gameModel: gameModel)
        let dramaticReveal = eliminationView.getDramaticReveal()
        
        #expect(dramaticReveal.eliminatedPlayer == "Bob", "Should show eliminated player")
        #expect(dramaticReveal.hasDelay, "Should have dramatic delay")
        #expect(dramaticReveal.delayDuration > 0, "Delay should be positive")
    }
    
    // MARK: - Game Over UI Tests
    
    @Test("GameOverView reveals all information")
    func gameOverViewRevealsAllInformation() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .gameOver
        gameModel.gameOutcome = .villagersWin
        
        let gameOverView = GameOverView(gameModel: gameModel)
        let finalResults = gameOverView.getFinalResults()
        
        #expect(finalResults.revealAllRoles, "Should reveal all roles")
        #expect(finalResults.showGameHistory, "Should show game history")
        #expect(finalResults.winningTeam == .villager, "Should show winning team")
        
        // All player roles should be visible
        for player in gameModel.players {
            let playerInfo = gameOverView.getPlayerFinalInfo(player.name)
            #expect(playerInfo.role != nil, "All roles should be revealed")
        }
    }
    
    @Test("GameOverView provides play again option")
    func gameOverViewProvidesPlayAgainOption() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .gameOver
        
        let gameOverView = GameOverView(gameModel: gameModel)
        let playAgainUI = gameOverView.getPlayAgainUI()
        
        #expect(playAgainUI.available, "Play again should be available")
        #expect(playAgainUI.keepsPlayers, "Should offer to keep same players")
        #expect(playAgainUI.allowsNewSetup, "Should allow new setup")
    }
    
    // MARK: - Device Passing Coordination Tests
    
    @Test("Device passing instructions are phase-appropriate")
    func devicePassingInstructionsArePhaseAppropriate() {
        let gameModel = createTestGame()
        
        let phases: [GamePhase] = [.roleReveal, .nightPhase, .voting]
        
        for phase in phases {
            gameModel.currentPhase = phase
            gameModel.currentPlayerIndex = 0
            
            let instructions = gameModel.currentDevicePassingInstructions()
            
            switch phase {
            case .roleReveal:
                #expect(instructions.what.contains("role"), "Role reveal should mention role")
            case .nightPhase:
                #expect(instructions.what.contains("action") || instructions.what.contains("choice"), "Night phase should mention actions")
            case .voting:
                #expect(instructions.what.contains("vote"), "Voting phase should mention voting")
            default:
                break
            }
            
            #expect(!instructions.who.isEmpty, "Should specify who takes device")
            #expect(!instructions.when.isEmpty, "Should specify when to return device")
        }
    }
    
    @Test("Device coordination handles eliminated players")
    func deviceCoordinationHandlesEliminatedPlayers() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .voting
        
        // Eliminate a player
        gameModel.eliminatePlayer("Bob")
        
        // Start device passing
        gameModel.currentPlayerIndex = 0
        let alivePlayers = gameModel.alivePlayers()
        
        #expect(!alivePlayers.contains { $0.name == "Bob" }, "Eliminated player should not be in alive list")
        
        // Device passing should skip eliminated players
        var instructions = gameModel.currentDevicePassingInstructions()
        #expect(instructions.who != "Bob", "Should not pass to eliminated player")
        
        // Advance through all alive players
        var visitedPlayers: Set<String> = []
        while gameModel.currentPlayerIndex != nil {
            instructions = gameModel.currentDevicePassingInstructions()
            visitedPlayers.insert(instructions.who)
            gameModel.advanceCurrentPlayer()
        }
        
        #expect(!visitedPlayers.contains("Bob"), "Should never visit eliminated player")
    }
    
    // MARK: - Accessibility in Game Flow Tests
    
    @Test("Game flow views support accessibility")
    func gameFlowViewsSupportAccessibility() {
        let gameModel = createTestGame()
        
        let views = [
            RoleRevealView(gameModel: gameModel),
            NightPhaseView(gameModel: gameModel),
            VotingView(gameModel: gameModel)
        ]
        
        for view in views {
            let accessibilityInfo = view.getAccessibilityInfo()
            
            #expect(!accessibilityInfo.labels.isEmpty, "Should have accessibility labels")
            #expect(!accessibilityInfo.hints.isEmpty, "Should have accessibility hints")
            #expect(accessibilityInfo.supportsVoiceOver, "Should support VoiceOver")
            #expect(accessibilityInfo.privacyAware, "Should be privacy-aware for shared device")
        }
    }
    
    @Test("Device passing instructions work with VoiceOver")
    func devicePassingInstructionsWorkWithVoiceOver() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .roleReveal
        gameModel.currentPlayerIndex = 0
        
        let instructions = gameModel.currentDevicePassingInstructions()
        let voiceOverText = instructions.voiceOverDescription
        
        #expect(!voiceOverText.isEmpty, "Should have VoiceOver description")
        #expect(voiceOverText.contains(instructions.who), "Should include player name")
        #expect(voiceOverText.contains("device"), "Should mention device")
    }
    
    // MARK: - Error Handling in Game Flow Tests
    
    @Test("Game flow handles unexpected state transitions")
    func gameFlowHandlesUnexpectedStateTransitions() {
        let gameModel = createTestGame()
        
        // Try to access voting UI during setup
        gameModel.currentPhase = .setup
        let votingView = VotingView(gameModel: gameModel)
        let votingUI = votingView.getVotingInterface()
        
        #expect(!votingUI.isAvailable, "Voting should not be available during setup")
        #expect(votingUI.errorMessage != nil, "Should provide error message")
    }
    
    @Test("Game flow validates user actions")
    func gameFlowValidatesUserActions() {
        let gameModel = createTestGame()
        gameModel.currentPhase = .nightPhase
        
        let nightPhaseView = NightPhaseView(gameModel: gameModel)
        
        // Try invalid werewolf action (targeting another werewolf)
        nightPhaseView.setCurrentViewer("Alice") // Assume Alice is werewolf
        if gameModel.playerRole(for: "Alice") == .werewolf {
            // Find another werewolf
            if let otherWerewolf = gameModel.players.first(where: { 
                $0.name != "Alice" && gameModel.playerRole(for: $0.name) == .werewolf 
            }) {
                let actionResult = nightPhaseView.performWerewolfAction(target: otherWerewolf.name)
                #expect(!actionResult.success, "Should not allow werewolf to target werewolf")
                #expect(actionResult.errorMessage != nil, "Should provide error message")
            }
        }
    }
}

// MARK: - Test Helper Functions

extension GameFlowTests {
    
    /// Creates a test game with 6 players and assigned roles
    private func createTestGame() -> GameModel {
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        gameModel.startGame()
        return gameModel
    }
}

// MARK: - Mock Game Flow UI Components

/// Mock RoleRevealView for testing
class RoleRevealView {
    let gameModel: GameModel
    private var currentViewer: String?
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func setCurrentViewer(_ playerName: String) {
        currentViewer = playerName
    }
    
    func getCurrentPlayerRole() -> Role? {
        guard let viewer = currentViewer else { return nil }
        return gameModel.playerRole(for: viewer)
    }
    
    func getOtherPlayersInfo() -> [VisiblePlayerInfo] {
        guard let viewer = currentViewer else { return [] }
        
        return gameModel.players.compactMap { player in
            guard player.name != viewer else { return nil }
            return gameModel.visiblePlayerInfo(for: player.name, viewedBy: viewer)
        }
    }
    
    func getDevicePassingInstructions() -> DevicePassingInstructions {
        return gameModel.currentDevicePassingInstructions()
    }
    
    func getAccessibilityInfo() -> GameFlowAccessibilityInfo {
        return GameFlowAccessibilityInfo(
            labels: ["Role Name", "Role Description", "Pass Device Button"],
            hints: ["Your secret role", "Role abilities and win condition", "Pass device to next player"],
            supportsVoiceOver: true,
            privacyAware: true
        )
    }
}

/// Mock NightPhaseView for testing
class NightPhaseView {
    let gameModel: GameModel
    private var currentViewer: String?
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func setCurrentViewer(_ playerName: String) {
        currentViewer = playerName
    }
    
    func getWerewolfActionUI() -> WerewolfActionUI {
        guard let viewer = currentViewer,
              gameModel.playerRole(for: viewer) == .werewolf else {
            return WerewolfActionUI(canSelectTarget: false, availableTargets: [])
        }
        
        let targets = gameModel.alivePlayers()
            .filter { $0.name != viewer && gameModel.playerRole(for: $0.name) != .werewolf }
            .map { $0.name }
        
        return WerewolfActionUI(canSelectTarget: true, availableTargets: targets)
    }
    
    func getSeerActionUI() -> SeerActionUI {
        guard let viewer = currentViewer,
              gameModel.playerRole(for: viewer) == .seer else {
            return SeerActionUI(canInvestigate: false, availableTargets: [])
        }
        
        let targets = gameModel.alivePlayers()
            .filter { $0.name != viewer }
            .map { $0.name }
        
        return SeerActionUI(canInvestigate: true, availableTargets: targets)
    }
    
    func getDoctorActionUI() -> DoctorActionUI {
        guard let viewer = currentViewer,
              gameModel.playerRole(for: viewer) == .doctor else {
            return DoctorActionUI(canProtect: false, availableTargets: [])
        }
        
        let targets = gameModel.alivePlayers().map { $0.name }
        
        return DoctorActionUI(canProtect: true, availableTargets: targets)
    }
    
    func getVillagerNightUI() -> VillagerNightUI {
        return VillagerNightUI(
            hasActions: false,
            showWaitingMessage: true,
            message: "Close your eyes and wait for morning"
        )
    }
    
    func getVisiblePlayers() -> [VisiblePlayerInfo] {
        guard let viewer = currentViewer else { return [] }
        
        return gameModel.players.map { player in
            gameModel.visiblePlayerInfo(for: player.name, viewedBy: viewer)
        }
    }
    
    func performWerewolfAction(target: String) -> ActionResult {
        guard let viewer = currentViewer,
              gameModel.playerRole(for: viewer) == .werewolf else {
            return ActionResult(success: false, errorMessage: "Only werewolves can perform this action")
        }
        
        // Check if target is valid (not another werewolf)
        if gameModel.playerRole(for: target) == .werewolf {
            return ActionResult(success: false, errorMessage: "Cannot target another werewolf")
        }
        
        return ActionResult(success: true, errorMessage: nil)
    }
    
    func getAccessibilityInfo() -> GameFlowAccessibilityInfo {
        return GameFlowAccessibilityInfo(
            labels: ["Night Action", "Target Selection", "Confirm Action"],
            hints: ["Choose your night action", "Select target player", "Confirm your choice"],
            supportsVoiceOver: true,
            privacyAware: true
        )
    }
}

/// Mock DayPhaseView for testing
class DayPhaseView {
    let gameModel: GameModel
    private var timerEnabled = false
    private var timerDuration: TimeInterval = 0
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func getDiscussionUI() -> DiscussionUI {
        return DiscussionUI(
            deviceIsShared: true,
            allowsOpenTalk: true,
            showPrivateInfo: false
        )
    }
    
    func getNightResults() -> NightResults {
        let eliminatedPlayers = gameModel.players.filter { !$0.isAlive }
        
        return NightResults(
            hasElimination: !eliminatedPlayers.isEmpty,
            eliminatedPlayer: eliminatedPlayers.last?.name,
            showCauseOfDeath: false
        )
    }
    
    func enableTimer(duration: TimeInterval) {
        timerEnabled = true
        timerDuration = duration
    }
    
    func getTimerInfo() -> TimerInfo {
        return TimerInfo(isEnabled: timerEnabled, duration: timerDuration)
    }
}

/// Mock VotingView for testing
class VotingView {
    let gameModel: GameModel
    private var currentVoter: String?
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func setCurrentVoter(_ playerName: String) {
        currentVoter = playerName
    }
    
    func getVotingInterface() -> VotingInterface {
        if gameModel.currentPhase != .voting {
            return VotingInterface(
                isPrivate: false,
                availableTargets: [],
                isAvailable: false,
                errorMessage: "Voting not available in current phase"
            )
        }
        
        let targets = gameModel.alivePlayers().map { $0.name }
        
        return VotingInterface(
            isPrivate: true,
            availableTargets: targets,
            isAvailable: true,
            errorMessage: nil
        )
    }
    
    func castVote(for target: String) -> VoteResult {
        guard let voter = currentVoter else {
            return VoteResult(success: false)
        }
        
        let success = gameModel.recordVote(from: voter, for: target)
        return VoteResult(success: success)
    }
    
    func getVoteDisplay() -> VoteDisplay {
        let votingStatus = gameModel.visibleVoteStatus()
        
        return VoteDisplay(
            showTallies: gameModel.currentPhase == .elimination,
            showVotingStatus: true,
            votingStatus: votingStatus
        )
    }
    
    func getDeviceHandoffInstructions() -> DevicePassingInstructions {
        return gameModel.currentDevicePassingInstructions()
    }
    
    func getAccessibilityInfo() -> GameFlowAccessibilityInfo {
        return GameFlowAccessibilityInfo(
            labels: ["Vote Target", "Cast Vote", "Confirm Vote"],
            hints: ["Choose who to vote for", "Cast your vote", "Confirm your choice"],
            supportsVoiceOver: true,
            privacyAware: true
        )
    }
}

/// Mock EliminationView for testing
class EliminationView {
    let gameModel: GameModel
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func getVotingResults() -> VotingResultsDisplay {
        let results = gameModel.votingResults()
        let eliminated = results?.max(by: { $0.value < $1.value })?.key
        
        return VotingResultsDisplay(
            showVoteTallies: true,
            eliminatedPlayer: eliminated,
            revealRoles: false
        )
    }
    
    func getDramaticReveal() -> DramaticReveal {
        let eliminatedPlayer = gameModel.players.first { !$0.isAlive }?.name
        
        return DramaticReveal(
            eliminatedPlayer: eliminatedPlayer,
            hasDelay: true,
            delayDuration: GameConstants.dramaticRevealDelay
        )
    }
}

/// Mock GameOverView for testing
class GameOverView {
    let gameModel: GameModel
    
    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func getFinalResults() -> FinalResults {
        return FinalResults(
            revealAllRoles: true,
            showGameHistory: true,
            winningTeam: gameModel.gameOutcome == .villagersWin ? .villager : .werewolf
        )
    }
    
    func getPlayerFinalInfo(_ playerName: String) -> PlayerFinalInfo {
        let role = gameModel.playerRole(for: playerName)
        let isAlive = gameModel.isPlayerAlive(playerName)
        
        return PlayerFinalInfo(name: playerName, role: role, isAlive: isAlive)
    }
    
    func getPlayAgainUI() -> PlayAgainUI {
        return PlayAgainUI(
            available: true,
            keepsPlayers: true,
            allowsNewSetup: true
        )
    }
}

// MARK: - Supporting Types for Game Flow Tests

struct GameFlowAccessibilityInfo {
    let labels: [String]
    let hints: [String]
    let supportsVoiceOver: Bool
    let privacyAware: Bool
}

struct WerewolfActionUI {
    let canSelectTarget: Bool
    let availableTargets: [String]
}

struct SeerActionUI {
    let canInvestigate: Bool
    let availableTargets: [String]
}

struct DoctorActionUI {
    let canProtect: Bool
    let availableTargets: [String]
}

struct VillagerNightUI {
    let hasActions: Bool
    let showWaitingMessage: Bool
    let message: String
}

struct ActionResult {
    let success: Bool
    let errorMessage: String?
}

struct DiscussionUI {
    let deviceIsShared: Bool
    let allowsOpenTalk: Bool
    let showPrivateInfo: Bool
}

struct NightResults {
    let hasElimination: Bool
    let eliminatedPlayer: String?
    let showCauseOfDeath: Bool
}

struct TimerInfo {
    let isEnabled: Bool
    let duration: TimeInterval
}

struct VotingInterface {
    let isPrivate: Bool
    let availableTargets: [String]
    let isAvailable: Bool
    let errorMessage: String?
}

struct VoteResult {
    let success: Bool
}

struct VoteDisplay {
    let showTallies: Bool
    let showVotingStatus: Bool
    let votingStatus: [String: Bool]
}

struct VotingResultsDisplay {
    let showVoteTallies: Bool
    let eliminatedPlayer: String?
    let revealRoles: Bool
}

struct DramaticReveal {
    let eliminatedPlayer: String?
    let hasDelay: Bool
    let delayDuration: TimeInterval
}

struct FinalResults {
    let revealAllRoles: Bool
    let showGameHistory: Bool
    let winningTeam: Team
}

struct PlayerFinalInfo {
    let name: String
    let role: Role?
    let isAlive: Bool
}

struct PlayAgainUI {
    let available: Bool
    let keepsPlayers: Bool
    let allowsNewSetup: Bool
}

// MARK: - Extensions for Testing

extension DevicePassingInstructions {
    var voiceOverDescription: String {
        return "\(who) should take the device. \(what) \(when)"
    }
}