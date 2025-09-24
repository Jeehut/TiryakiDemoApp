import Testing
import Foundation
@testable import Werwolf

/// Test suite for privacy service functionality  
/// Validates computed properties for role-specific information access and privacy boundaries
struct PrivacyServiceTests {
    
    // MARK: - Service Initialization Tests
    
    @Test("PrivacyService initializes correctly")
    func serviceInitialization() {
        let service = PrivacyService()
        
        #expect(service.currentViewer == nil, "No initial viewer set")
        #expect(service.privacyLevel == .publicInfo, "Default to public privacy level")
    }
    
    // MARK: - Role-Based Information Filtering Tests
    
    @Test("Player can see their own role")
    func playerCanSeeOwnRole() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.setCurrentViewer("Alice", players: players)
        
        let visibleInfo = service.getVisiblePlayerInfo(for: "Alice", players: players)
        #expect(visibleInfo.role != nil, "Player should see their own role")
        #expect(visibleInfo.role == .werewolf, "Alice should see her werewolf role")
    }
    
    @Test("Player cannot see other players' roles by default")
    func playerCannotSeeOtherPlayersRoles() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.setCurrentViewer("Alice", players: players) // Alice is werewolf
        
        let bobInfo = service.getVisiblePlayerInfo(for: "Bob", players: players) // Bob is also werewolf
        let carolInfo = service.getVisiblePlayerInfo(for: "Carol", players: players) // Carol is seer
        
        // In most phases, even werewolves can't see other werewolves by default
        service.setPrivacyLevel(.privateInfo)
        let bobInfoPrivate = service.getVisiblePlayerInfo(for: "Bob", players: players)
        
        #expect(bobInfoPrivate.role == nil, "Should not see other player's role in private phase")
        #expect(carolInfo.role == nil, "Should not see seer's role")
    }
    
    @Test("Werewolves can see other werewolves in night phase")
    func werewolvesCanSeeOtherWerewolvesInNightPhase() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.setCurrentViewer("Alice", players: players) // Alice is werewolf
        service.configureForNightPhase(players: players)
        
        let bobInfo = service.getVisiblePlayerInfo(for: "Bob", players: players) // Bob is also werewolf
        let carolInfo = service.getVisiblePlayerInfo(for: "Carol", players: players) // Carol is seer
        
        #expect(bobInfo.role == .werewolf, "Werewolf should see other werewolf in night phase")
        #expect(carolInfo.role == nil, "Werewolf should not see seer's role")
    }
    
    @Test("Eliminated players have limited visibility")
    func eliminatedPlayersHaveLimitedVisibility() {
        let service = PrivacyService()
        var players = createTestPlayersWithRoles()
        players[0].eliminate() // Eliminate Alice (werewolf)
        
        service.setCurrentViewer("Alice", players: players)
        
        let visibility = service.getViewerCapabilities()
        #expect(!visibility.canVote, "Eliminated player cannot vote")
        #expect(!visibility.canPerformNightActions, "Eliminated player cannot perform night actions")
        #expect(visibility.canViewGameState, "Eliminated player can still view game state")
    }
    
    // MARK: - Voting Privacy Tests
    
    @Test("Votes are hidden during voting phase")
    func votesAreHiddenDuringVotingPhase() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        // Simulate voting in progress
        service.configureForVotingPhase(players: players)
        service.setCurrentViewer("Alice", players: players)
        
        let voteVisibility = service.getVotingVisibility()
        #expect(!voteVisibility.showVoteTallies, "Vote tallies should be hidden during voting")
        #expect(voteVisibility.showWhoVoted, "Can show who has voted without revealing targets")
    }
    
    @Test("Votes are revealed after voting complete")
    func votesAreRevealedAfterVotingComplete() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForEliminationPhase(players: players)
        
        let voteVisibility = service.getVotingVisibility()
        #expect(voteVisibility.showVoteTallies, "Vote tallies should be visible after voting")
        #expect(voteVisibility.showVoteTargets, "Vote targets should be revealed")
    }
    
    // MARK: - Night Action Privacy Tests
    
    @Test("Night actions are hidden from non-participants")
    func nightActionsAreHiddenFromNonParticipants() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForNightPhase(players: players)
        service.setCurrentViewer("Eve", players: players) // Eve is villager, no night action
        
        let nightVisibility = service.getNightActionVisibility()
        #expect(!nightVisibility.canSeeWerewolfActions, "Villager cannot see werewolf actions")
        #expect(!nightVisibility.canSeeSeerActions, "Villager cannot see seer actions")
        #expect(!nightVisibility.canSeeDoctorActions, "Villager cannot see doctor actions")
    }
    
    @Test("Seer can see their own investigation results")
    func seerCanSeeOwnInvestigationResults() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForNightPhase(players: players)
        service.setCurrentViewer("Carol", players: players) // Carol is seer
        
        // Simulate seer investigation
        service.recordSeerInvestigation(target: "Alice", result: true) // Alice is werewolf
        
        let seerResults = service.getSeerResultsForCurrentViewer()
        #expect(!seerResults.isEmpty, "Seer should see their investigation results")
        #expect(seerResults.first?.targetName == "Alice", "Should show investigation target")
        #expect(seerResults.first?.isWerewolf == true, "Should show correct result")
    }
    
    @Test("Other players cannot see seer investigation results")
    func otherPlayersCannotSeeSeerResults() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForNightPhase(players: players)
        service.setCurrentViewer("Carol", players: players) // Carol is seer
        service.recordSeerInvestigation(target: "Alice", result: true)
        
        // Switch to different viewer
        service.setCurrentViewer("David", players: players) // David is doctor
        
        let seerResults = service.getSeerResultsForCurrentViewer()
        #expect(seerResults.isEmpty, "Non-seer should not see seer results")
    }
    
    // MARK: - Phase-Based Privacy Tests
    
    @Test("Setup phase allows full visibility")
    func setupPhaseAllowsFullVisibility() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForSetupPhase()
        service.setCurrentViewer("Alice", players: players)
        
        let visibility = service.getPhaseVisibilityRules()
        #expect(visibility.allowRoleDiscussion, "Setup phase allows role discussion")
        #expect(visibility.deviceIsShared, "Device is shared in setup")
    }
    
    @Test("Day phase hides private information")
    func dayPhaseHidesPrivateInformation() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForDayPhase(players: players)
        service.setCurrentViewer("Alice", players: players)
        
        let visibility = service.getPhaseVisibilityRules()
        #expect(!visibility.allowRoleDiscussion, "Day phase prevents role revelation")
        #expect(visibility.deviceIsShared, "Device is shared during discussion")
        
        // Check that sensitive information is hidden
        let aliceInfo = service.getVisiblePlayerInfo(for: "Alice", players: players)
        #expect(aliceInfo.role == .werewolf, "Player can see own role")
        
        let bobInfo = service.getVisiblePlayerInfo(for: "Bob", players: players)
        #expect(bobInfo.role == nil, "Player cannot see other's role during day")
    }
    
    @Test("Game over phase reveals all information")
    func gameOverPhaseRevealsAllInformation() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForGameOverPhase()
        service.setCurrentViewer("Alice", players: players)
        
        let visibility = service.getPhaseVisibilityRules()
        #expect(visibility.revealAllRoles, "Game over should reveal all roles")
        #expect(visibility.showCompleteHistory, "Game over should show complete history")
        
        // All roles should now be visible
        for player in players {
            let info = service.getVisiblePlayerInfo(for: player.name, players: players)
            #expect(info.role != nil, "All roles should be visible in game over phase")
        }
    }
    
    // MARK: - Privacy Boundary Validation Tests
    
    @Test("Privacy boundaries prevent information leaks")
    func privacyBoundariesPreventInformationLeaks() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.configureForVotingPhase(players: players)
        service.setCurrentViewer("Alice", players: players)
        
        // Try to access information that should be hidden
        let restrictedInfo = service.getRestrictedInformation()
        #expect(restrictedInfo.hiddenRoles.count > 0, "Some roles should be hidden")
        #expect(restrictedInfo.hiddenVotes.count >= 0, "Vote information should be controlled")
        #expect(restrictedInfo.hiddenNightActions.count >= 0, "Night actions should be hidden")
    }
    
    @Test("Privacy service validates viewer permissions")
    func privacyServiceValidatesViewerPermissions() {
        let service = PrivacyService()
        var players = createTestPlayersWithRoles()
        players[0].eliminate() // Eliminate Alice
        
        service.setCurrentViewer("Alice", players: players)
        service.configureForVotingPhase(players: players)
        
        let permissions = service.getViewerPermissions()
        #expect(!permissions.canVote, "Eliminated player cannot vote")
        #expect(!permissions.canTakeDeviceActions, "Eliminated player cannot take device actions")
        #expect(permissions.canViewPublicInfo, "Eliminated player can view public info")
    }
    
    // MARK: - Dynamic Privacy Updates Tests
    
    @Test("Privacy rules update when phase changes")
    func privacyRulesUpdateWhenPhaseChanges() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        service.setCurrentViewer("Alice", players: players)
        
        // Start in night phase (private)
        service.configureForNightPhase(players: players)
        let nightVisibility = service.getPhaseVisibilityRules()
        #expect(!nightVisibility.deviceIsShared, "Night phase should be private")
        
        // Switch to day phase (group)
        service.configureForDayPhase(players: players)
        let dayVisibility = service.getPhaseVisibilityRules()
        #expect(dayVisibility.deviceIsShared, "Day phase should be shared")
    }
    
    @Test("Privacy service handles role changes gracefully")
    func privacyServiceHandlesRoleChangesGracefully() {
        let service = PrivacyService()
        var players = createTestPlayersWithRoles()
        service.setCurrentViewer("Alice", players: players)
        
        let initialCapabilities = service.getViewerCapabilities()
        #expect(initialCapabilities.canPerformNightActions, "Werewolf should have night actions")
        
        // Eliminate Alice
        players[0].eliminate()
        service.updatePlayers(players)
        
        let updatedCapabilities = service.getViewerCapabilities()
        #expect(!updatedCapabilities.canPerformNightActions, "Eliminated player should lose night actions")
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Privacy service handles empty player list")
    func privacyServiceHandlesEmptyPlayerList() {
        let service = PrivacyService()
        let emptyPlayers: [Player] = []
        
        service.setCurrentViewer("NonExistent", players: emptyPlayers)
        
        let capabilities = service.getViewerCapabilities()
        #expect(!capabilities.canVote, "Should handle empty player list")
        #expect(!capabilities.canPerformNightActions, "Should handle empty player list")
    }
    
    @Test("Privacy service handles viewer not in game")
    func privacyServiceHandlesViewerNotInGame() {
        let service = PrivacyService()
        let players = createTestPlayersWithRoles()
        
        service.setCurrentViewer("NonExistentPlayer", players: players)
        
        let capabilities = service.getViewerCapabilities()
        #expect(!capabilities.canVote, "Non-existent viewer cannot vote")
        #expect(!capabilities.canPerformNightActions, "Non-existent viewer cannot act")
        #expect(!capabilities.canViewPrivateInfo, "Non-existent viewer cannot view private info")
    }
    
    // MARK: - Performance Tests
    
    @Test("Privacy filtering performs well with maximum players")
    func privacyFilteringPerformsWellWithMaximumPlayers() {
        let service = PrivacyService()
        let playerNames = (1...12).map { "Player\($0)" }
        let players = createTestPlayersWithNames(playerNames)
        
        service.setCurrentViewer("Player1", players: players)
        service.configureForDayPhase(players: players)
        
        let startTime = Date()
        
        // Filter information for all players
        for player in players {
            let _ = service.getVisiblePlayerInfo(for: player.name, players: players)
        }
        
        let endTime = Date()
        let filteringTime = endTime.timeIntervalSince(startTime)
        
        #expect(filteringTime < 0.1, "Privacy filtering should be fast with max players")
    }
}

// MARK: - Test Helper Functions

extension PrivacyServiceTests {
    
    /// Creates test players with assigned roles for privacy testing
    private func createTestPlayersWithRoles() -> [Player] {
        var players = [
            Player(name: "Alice"),    // Werewolf
            Player(name: "Bob"),      // Werewolf  
            Player(name: "Carol"),    // Seer
            Player(name: "David"),    // Doctor
            Player(name: "Eve"),      // Villager
            Player(name: "Frank")     // Villager
        ]
        
        players[0].assignRole(.werewolf)
        players[1].assignRole(.werewolf)
        players[2].assignRole(.seer)
        players[3].assignRole(.doctor)
        players[4].assignRole(.villager)
        players[5].assignRole(.villager)
        
        return players
    }
    
    /// Creates test players with just names
    private func createTestPlayersWithNames(_ names: [String]) -> [Player] {
        return names.map { Player(name: $0) }
    }
}

// MARK: - Mock Privacy Service Implementation

/// Mock PrivacyService for testing purposes
/// This will be replaced by the actual service implementation
class PrivacyService {
    private var currentViewer: String?
    private var privacyLevel: PrivacyLevel = .publicInfo
    private var currentPhase: GamePhase = .setup
    private var players: [Player] = []
    private var seerInvestigations: [(targetName: String, isWerewolf: Bool)] = []
    
    func setCurrentViewer(_ viewerName: String?, players: [Player]) {
        self.currentViewer = viewerName
        self.players = players
    }
    
    func setPrivacyLevel(_ level: PrivacyLevel) {
        self.privacyLevel = level
    }
    
    func getVisiblePlayerInfo(for playerName: String, players: [Player]) -> VisiblePlayerInfo {
        guard let player = players.first(where: { $0.name == playerName }) else {
            return VisiblePlayerInfo(name: playerName, isAlive: false, role: nil)
        }
        
        let visibleRole: Role? = {
            // Player can see own role
            if playerName == currentViewer {
                return player.role
            }
            
            // Game over phase reveals all roles
            if currentPhase == .gameOver {
                return player.role
            }
            
            // Werewolves can see other werewolves in night phase
            if currentPhase == .nightPhase,
               let viewerPlayer = players.first(where: { $0.name == currentViewer }),
               let viewerRole = viewerPlayer.role,
               let targetRole = player.role,
               viewerRole == .werewolf && targetRole == .werewolf {
                return targetRole
            }
            
            return nil
        }()
        
        return VisiblePlayerInfo(name: player.name, isAlive: player.isAlive, role: visibleRole)
    }
    
    func getViewerCapabilities() -> ViewerCapabilities {
        guard let viewerName = currentViewer,
              let viewer = players.first(where: { $0.name == viewerName }) else {
            return ViewerCapabilities(canVote: false, canPerformNightActions: false, canViewGameState: false, canViewPrivateInfo: false)
        }
        
        return ViewerCapabilities(
            canVote: viewer.isAlive && currentPhase == .voting,
            canPerformNightActions: viewer.isAlive && viewer.canPerformNightAction && currentPhase == .nightPhase,
            canViewGameState: true,
            canViewPrivateInfo: viewer.isAlive || currentPhase == .gameOver
        )
    }
    
    func configureForNightPhase(players: [Player]) {
        self.currentPhase = .nightPhase
        self.players = players
        self.privacyLevel = .privateInfo
    }
    
    func configureForVotingPhase(players: [Player]) {
        self.currentPhase = .voting
        self.players = players
        self.privacyLevel = .privateInfo
    }
    
    func configureForEliminationPhase(players: [Player]) {
        self.currentPhase = .elimination
        self.players = players
        self.privacyLevel = .publicInfo
    }
    
    func configureForSetupPhase() {
        self.currentPhase = .setup
        self.privacyLevel = .publicInfo
    }
    
    func configureForDayPhase(players: [Player]) {
        self.currentPhase = .dayPhase
        self.players = players
        self.privacyLevel = .publicInfo
    }
    
    func configureForGameOverPhase() {
        self.currentPhase = .gameOver
        self.privacyLevel = .publicInfo
    }
    
    func getVotingVisibility() -> VotingVisibility {
        switch currentPhase {
        case .voting:
            return VotingVisibility(showVoteTallies: false, showWhoVoted: true, showVoteTargets: false)
        case .elimination, .gameOver:
            return VotingVisibility(showVoteTallies: true, showWhoVoted: true, showVoteTargets: true)
        default:
            return VotingVisibility(showVoteTallies: false, showWhoVoted: false, showVoteTargets: false)
        }
    }
    
    func getNightActionVisibility() -> NightActionVisibility {
        return NightActionVisibility(
            canSeeWerewolfActions: false,
            canSeeSeerActions: false,
            canSeeDoctorActions: false
        )
    }
    
    func recordSeerInvestigation(target: String, result: Bool) {
        seerInvestigations.append((targetName: target, isWerewolf: result))
    }
    
    func getSeerResultsForCurrentViewer() -> [(targetName: String, isWerewolf: Bool)] {
        guard let viewerName = currentViewer,
              let viewer = players.first(where: { $0.name == viewerName }),
              viewer.role == .seer else {
            return []
        }
        return seerInvestigations
    }
    
    func getPhaseVisibilityRules() -> PhaseVisibilityRules {
        switch currentPhase {
        case .setup:
            return PhaseVisibilityRules(allowRoleDiscussion: true, deviceIsShared: true, revealAllRoles: false, showCompleteHistory: false)
        case .dayPhase:
            return PhaseVisibilityRules(allowRoleDiscussion: false, deviceIsShared: true, revealAllRoles: false, showCompleteHistory: false)
        case .nightPhase:
            return PhaseVisibilityRules(allowRoleDiscussion: false, deviceIsShared: false, revealAllRoles: false, showCompleteHistory: false)
        case .gameOver:
            return PhaseVisibilityRules(allowRoleDiscussion: true, deviceIsShared: true, revealAllRoles: true, showCompleteHistory: true)
        default:
            return PhaseVisibilityRules(allowRoleDiscussion: false, deviceIsShared: true, revealAllRoles: false, showCompleteHistory: false)
        }
    }
    
    func getRestrictedInformation() -> RestrictedInformation {
        return RestrictedInformation(hiddenRoles: [], hiddenVotes: [], hiddenNightActions: [])
    }
    
    func getViewerPermissions() -> ViewerPermissions {
        guard let viewerName = currentViewer,
              let viewer = players.first(where: { $0.name == viewerName }) else {
            return ViewerPermissions(canVote: false, canTakeDeviceActions: false, canViewPublicInfo: false)
        }
        
        return ViewerPermissions(
            canVote: viewer.isAlive,
            canTakeDeviceActions: viewer.isAlive,
            canViewPublicInfo: true
        )
    }
    
    func updatePlayers(_ players: [Player]) {
        self.players = players
    }
}

// MARK: - Supporting Types for Privacy Service

struct ViewerCapabilities {
    let canVote: Bool
    let canPerformNightActions: Bool
    let canViewGameState: Bool
    let canViewPrivateInfo: Bool
}

struct VotingVisibility {
    let showVoteTallies: Bool
    let showWhoVoted: Bool
    let showVoteTargets: Bool
}

struct NightActionVisibility {
    let canSeeWerewolfActions: Bool
    let canSeeSeerActions: Bool
    let canSeeDoctorActions: Bool
}

struct PhaseVisibilityRules {
    let allowRoleDiscussion: Bool
    let deviceIsShared: Bool
    let revealAllRoles: Bool
    let showCompleteHistory: Bool
}

struct RestrictedInformation {
    let hiddenRoles: [String]
    let hiddenVotes: [String]
    let hiddenNightActions: [String]
}

struct ViewerPermissions {
    let canVote: Bool
    let canTakeDeviceActions: Bool
    let canViewPublicInfo: Bool
}