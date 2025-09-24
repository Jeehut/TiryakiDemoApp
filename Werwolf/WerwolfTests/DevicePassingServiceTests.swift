import Testing
import Foundation
@testable import Werwolf

/// Test suite for device passing coordination service
/// Validates WHO/WHAT/WHEN instruction generation and device handoff state management
struct DevicePassingServiceTests {
    
    // MARK: - Service Initialization Tests
    
    @Test("DevicePassingService initializes correctly")
    func serviceInitialization() {
        let service = DevicePassingService()
        
        #expect(service.currentDeviceHolder == nil, "No initial device holder")
        #expect(!service.isDeviceInUse, "Device should not be in use initially")
        #expect(service.currentInstructions == nil, "No initial instructions")
    }
    
    // MARK: - Device Handoff Tests
    
    @Test("Device handoff to specific player")
    func deviceHandoffToPlayer() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice", "Bob", "Carol"])
        
        // Hand device to Alice
        let handoffResult = service.handDeviceToPlayer("Alice", players: players, phase: .roleReveal)
        
        #expect(handoffResult.success, "Handoff should succeed")
        #expect(service.currentDeviceHolder == "Alice", "Alice should have device")
        #expect(service.isDeviceInUse, "Device should be in use")
        #expect(service.currentInstructions != nil, "Instructions should be available")
    }
    
    @Test("Device handoff to non-existent player fails")
    func deviceHandoffToNonExistentPlayer() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice", "Bob"])
        
        // Try to hand device to non-existent player
        let handoffResult = service.handDeviceToPlayer("Charlie", players: players, phase: .roleReveal)
        
        #expect(!handoffResult.success, "Handoff should fail")
        #expect(service.currentDeviceHolder == nil, "No device holder should be set")
        #expect(!service.isDeviceInUse, "Device should not be in use")
    }
    
    @Test("Device handoff to eliminated player fails")  
    func deviceHandoffToEliminatedPlayer() {
        let service = DevicePassingService()
        var players = createTestPlayers(names: ["Alice", "Bob"])
        players[0].eliminate() // Eliminate Alice
        
        // Try to hand device to eliminated player
        let handoffResult = service.handDeviceToPlayer("Alice", players: players, phase: .voting)
        
        #expect(!handoffResult.success, "Handoff to eliminated player should fail")
        #expect(handoffResult.errorMessage?.contains("eliminated"), "Error should mention elimination")
    }
    
    // MARK: - Instruction Generation Tests
    
    @Test("Role reveal instructions generation")
    func roleRevealInstructionsGeneration() {
        let service = DevicePassingService()
        let players = createTestPlayersWithRoles()
        
        let instructions = service.generateInstructions(
            for: "Alice", 
            players: players, 
            phase: .roleReveal
        )
        
        #expect(instructions.who == "Alice", "Instructions should be for Alice")
        #expect(instructions.what.contains("role"), "Instructions should mention role")
        #expect(instructions.when.contains("after"), "Instructions should provide return timing")
    }
    
    @Test("Night phase instructions for werewolf")
    func nightPhaseInstructionsForWerewolf() {
        let service = DevicePassingService()
        let players = createTestPlayersWithRoles()
        
        // Assuming Alice is a werewolf in our test data
        let werewolfPlayer = players.first { $0.role == .werewolf }!
        let instructions = service.generateInstructions(
            for: werewolfPlayer.name,
            players: players,
            phase: .nightPhase
        )
        
        #expect(instructions.who == werewolfPlayer.name, "Instructions should be for werewolf")
        #expect(instructions.what.contains("eliminate"), "Instructions should mention elimination")
        #expect(instructions.what.contains("werewolf"), "Instructions should reference werewolf role")
    }
    
    @Test("Night phase instructions for seer")
    func nightPhaseInstructionsForSeer() {
        let service = DevicePassingService()
        let players = createTestPlayersWithRoles()
        
        let seerPlayer = players.first { $0.role == .seer }!
        let instructions = service.generateInstructions(
            for: seerPlayer.name,
            players: players,
            phase: .nightPhase
        )
        
        #expect(instructions.who == seerPlayer.name, "Instructions should be for seer")
        #expect(instructions.what.contains("investigate"), "Instructions should mention investigation")
        #expect(instructions.what.contains("seer"), "Instructions should reference seer role")
    }
    
    @Test("Voting phase instructions")
    func votingPhaseInstructions() {
        let service = DevicePassingService()
        let players = createTestPlayersWithRoles()
        
        let instructions = service.generateInstructions(
            for: "Bob",
            players: players,
            phase: .voting
        )
        
        #expect(instructions.who == "Bob", "Instructions should be for Bob")
        #expect(instructions.what.contains("vote"), "Instructions should mention voting")
        #expect(instructions.when.contains("next"), "Instructions should mention next player")
    }
    
    // MARK: - Device State Management Tests
    
    @Test("Device return to center")
    func deviceReturnToCenter() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice", "Bob"])
        
        // Give device to Alice first
        service.handDeviceToPlayer("Alice", players: players, phase: .roleReveal)
        #expect(service.isDeviceInUse, "Device should be in use")
        
        // Return device to center
        service.returnDeviceToCenter()
        
        #expect(service.currentDeviceHolder == nil, "Device should have no holder")
        #expect(!service.isDeviceInUse, "Device should not be in use")
        #expect(service.currentInstructions == nil, "Instructions should be cleared")
    }
    
    @Test("Device usage timeout handling")
    func deviceUsageTimeoutHandling() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice"])
        
        // Hand device with short timeout
        service.handDeviceToPlayer("Alice", players: players, phase: .roleReveal)
        service.setDeviceTimeout(duration: 0.1) // 0.1 seconds
        
        // Wait for timeout
        let expectation = XCTestExpectation(description: "Device timeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            #expect(service.hasDeviceTimedOut, "Device should have timed out")
            expectation.fulfill()
        }
    }
    
    // MARK: - Sequential Device Passing Tests
    
    @Test("Sequential device passing through all players")
    func sequentialDevicePassingThroughAllPlayers() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice", "Bob", "Carol"])
        
        // Set up sequential passing
        service.startSequentialPassing(players: players, phase: .roleReveal)
        
        // First player should have device
        #expect(service.currentDeviceHolder == "Alice", "Alice should have device first")
        
        // Advance to next player
        let nextResult = service.advanceToNextPlayer()
        #expect(nextResult.success, "Should successfully advance")
        #expect(service.currentDeviceHolder == "Bob", "Bob should have device second")
        
        // Advance to final player
        service.advanceToNextPlayer()
        #expect(service.currentDeviceHolder == "Carol", "Carol should have device third")
        
        // Complete sequence
        service.advanceToNextPlayer()
        #expect(service.currentDeviceHolder == nil, "Device should return to center after sequence")
    }
    
    @Test("Sequential passing skips eliminated players")
    func sequentialPassingSkipsEliminatedPlayers() {
        let service = DevicePassingService()
        var players = createTestPlayers(names: ["Alice", "Bob", "Carol", "David"])
        players[1].eliminate() // Eliminate Bob
        players[3].eliminate() // Eliminate David
        
        service.startSequentialPassing(players: players, phase: .voting)
        
        // Should start with first alive player
        #expect(service.currentDeviceHolder == "Alice", "Should start with Alice")
        
        // Should skip Bob (eliminated) and go to Carol
        service.advanceToNextPlayer()
        #expect(service.currentDeviceHolder == "Carol", "Should skip Bob and go to Carol")
        
        // Should complete sequence (skipping David)
        service.advanceToNextPlayer()
        #expect(service.currentDeviceHolder == nil, "Should complete sequence")
    }
    
    // MARK: - Phase-Specific Device Coordination Tests
    
    @Test("Night phase device coordination")
    func nightPhaseDeviceCoordination() {
        let service = DevicePassingService()
        let players = createTestPlayersWithRoles()
        
        // Start night phase coordination
        let nightCoordination = service.coordinateNightPhase(players: players)
        
        #expect(!nightCoordination.isEmpty, "Should have night coordination steps")
        
        // Check that werewolves and special roles are included
        let werewolfSteps = nightCoordination.filter { $0.targetRole == .werewolf }
        let seerSteps = nightCoordination.filter { $0.targetRole == .seer }
        
        #expect(!werewolfSteps.isEmpty, "Should include werewolf coordination")
        #expect(!seerSteps.isEmpty, "Should include seer coordination")
    }
    
    @Test("Group phase device positioning")
    func groupPhaseDevicePositioning() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice", "Bob", "Carol"])
        
        // Set up group phase
        service.configureForGroupPhase(phase: .dayPhase)
        
        #expect(service.currentDeviceHolder == nil, "Device should be in center for group phase")
        #expect(!service.isDeviceInUse, "Device should not be in use for group phase")
        
        let groupInstructions = service.getGroupPhaseInstructions(phase: .dayPhase)
        #expect(groupInstructions.contains("center"), "Instructions should mention center")
        #expect(groupInstructions.contains("everyone"), "Instructions should mention everyone")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Invalid phase transitions handled gracefully")
    func invalidPhaseTransitionsHandledGracefully() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice"])
        
        // Try to coordinate night phase with no special roles
        let players_no_special = createTestPlayers(names: ["Alice"])
        let coordination = service.coordinateNightPhase(players: players_no_special)
        
        #expect(coordination.isEmpty, "Should handle no night actors gracefully")
    }
    
    @Test("Device handoff during incorrect phase")
    func deviceHandoffDuringIncorrectPhase() {
        let service = DevicePassingService()
        let players = createTestPlayers(names: ["Alice"])
        
        // Try to hand device for private action during group phase
        let result = service.handDeviceToPlayer("Alice", players: players, phase: .dayPhase)
        
        #expect(!result.success, "Should fail during group phase")
        #expect(result.errorMessage?.contains("group"), "Error should mention group phase")
    }
    
    // MARK: - Performance Tests
    
    @Test("Device coordination with maximum players")
    func deviceCoordinationWithMaximumPlayers() {
        let service = DevicePassingService()
        let playerNames = (1...12).map { "Player\($0)" }
        let players = createTestPlayers(names: playerNames)
        
        let startTime = Date()
        service.startSequentialPassing(players: players, phase: .voting)
        let endTime = Date()
        
        let setupTime = endTime.timeIntervalSince(startTime)
        #expect(setupTime < 0.1, "Setup should be fast even with max players")
        #expect(service.currentDeviceHolder == "Player1", "Should start with first player")
    }
}

// MARK: - Test Helper Functions

extension DevicePassingServiceTests {
    
    /// Creates test players with names only
    private func createTestPlayers(names: [String]) -> [Player] {
        return names.map { Player(name: $0) }
    }
    
    /// Creates test players with assigned roles
    private func createTestPlayersWithRoles() -> [Player] {
        var players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Carol"),
            Player(name: "David"),
            Player(name: "Eve"),
            Player(name: "Frank")
        ]
        
        // Assign roles using game utilities
        players[0].assignRole(.werewolf)
        players[1].assignRole(.werewolf)
        players[2].assignRole(.seer)
        players[3].assignRole(.doctor)
        players[4].assignRole(.villager)
        players[5].assignRole(.villager)
        
        return players
    }
}

// MARK: - Mock Service Types (to be implemented)

/// Mock DevicePassingService for testing purposes
/// This will be replaced by the actual service implementation
class DevicePassingService {
    private(set) var currentDeviceHolder: String?
    private(set) var isDeviceInUse: Bool = false
    private(set) var currentInstructions: DevicePassingInstructions?
    
    var hasDeviceTimedOut: Bool = false
    
    func handDeviceToPlayer(_ playerName: String, players: [Player], phase: GamePhase) -> HandoffResult {
        guard let player = players.first(where: { $0.name == playerName }) else {
            return HandoffResult(success: false, errorMessage: "Player not found")
        }
        
        guard player.isAlive else {
            return HandoffResult(success: false, errorMessage: "Player is eliminated")
        }
        
        guard phase.requiresPrivateDevicePass else {
            return HandoffResult(success: false, errorMessage: "Phase does not require device passing for group activities")
        }
        
        currentDeviceHolder = playerName
        isDeviceInUse = true
        currentInstructions = generateInstructions(for: playerName, players: players, phase: phase)
        
        return HandoffResult(success: true, errorMessage: nil)
    }
    
    func generateInstructions(for playerName: String, players: [Player], phase: GamePhase) -> DevicePassingInstructions {
        guard let player = players.first(where: { $0.name == playerName }) else {
            return DevicePassingInstructions(who: playerName, what: "Error", when: "Contact support")
        }
        
        let role = player.role
        
        switch phase {
        case .roleReveal:
            return DevicePassingInstructions(
                who: playerName,
                what: "Look at your secret role. Read it carefully and understand your abilities.",
                when: "After viewing your role, pass device to the next player"
            )
        case .nightPhase:
            if let role = role, role.hasNightAction {
                return DevicePassingInstructions(
                    who: playerName,
                    what: role.devicePassingInstructions(),
                    when: "After making your choice, pass device to the next night player"
                )
            } else {
                return DevicePassingInstructions(
                    who: playerName,
                    what: "You have no night action. Simply confirm and pass the device.",
                    when: "Immediately pass to next player"
                )
            }
        case .voting:
            return DevicePassingInstructions(
                who: playerName,
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
    
    func returnDeviceToCenter() {
        currentDeviceHolder = nil
        isDeviceInUse = false
        currentInstructions = nil
    }
    
    func setDeviceTimeout(duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hasDeviceTimedOut = true
        }
    }
    
    func startSequentialPassing(players: [Player], phase: GamePhase) {
        let alivePlayerNames = players.filter { $0.isAlive }.map { $0.name }
        currentDeviceHolder = alivePlayerNames.first
    }
    
    func advanceToNextPlayer() -> HandoffResult {
        // Simplified for testing
        currentDeviceHolder = nil
        return HandoffResult(success: true, errorMessage: nil)
    }
    
    func coordinateNightPhase(players: [Player]) -> [NightCoordinationStep] {
        return players.compactMap { player in
            if let role = player.role, role.hasNightAction {
                return NightCoordinationStep(playerName: player.name, targetRole: role)
            }
            return nil
        }
    }
    
    func configureForGroupPhase(phase: GamePhase) {
        returnDeviceToCenter()
    }
    
    func getGroupPhaseInstructions(phase: GamePhase) -> String {
        return "Device stays in center where everyone can see and participate."
    }
}

struct HandoffResult {
    let success: Bool
    let errorMessage: String?
}

struct NightCoordinationStep {
    let playerName: String
    let targetRole: Role
}