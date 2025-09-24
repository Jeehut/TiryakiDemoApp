import Testing
import Foundation
@testable import Werwolf

/// Test suite for Player model
/// Validates player state management, role assignment, and elimination tracking
struct PlayerModelTests {
    
    // MARK: - Player Initialization Tests
    
    @Test("Player initializes with correct properties")
    func playerInitialization() {
        let player = Player(name: "Alice")
        
        #expect(player.name == "Alice", "Player name should match initialization")
        #expect(player.isAlive, "Player should be alive initially")
        #expect(player.role == nil, "Player should have no role initially")
        #expect(player.votedFor == nil, "Player should have no vote initially")
    }
    
    @Test("Player name validation")
    func playerNameValidation() {
        // Valid names
        let validPlayer = Player(name: "Alice")
        #expect(!validPlayer.name.isEmpty, "Valid name should not be empty")
        
        // Test name trimming
        let paddedNamePlayer = Player(name: "  Bob  ")
        #expect(paddedNamePlayer.name == "Bob", "Player name should be trimmed")
    }
    
    // MARK: - Role Assignment Tests
    
    @Test("Role assignment works correctly")
    func roleAssignment() {
        var player = Player(name: "Alice")
        let werewolfRole = Role.werewolf
        
        player.assignRole(werewolfRole)
        #expect(player.role == werewolfRole, "Role should be assigned correctly")
        #expect(player.hasRole(.werewolf), "Player should have werewolf role")
        #expect(!player.hasRole(.villager), "Player should not have villager role")
    }
    
    @Test("Role capabilities validation")
    func roleCapabilities() {
        var seerPlayer = Player(name: "Seer")
        seerPlayer.assignRole(.seer)
        
        #expect(seerPlayer.canPerformNightAction, "Seer should be able to perform night actions")
        #expect(!seerPlayer.isWerewolf, "Seer should not be werewolf")
        #expect(seerPlayer.isVillager, "Seer should be villager team")
        
        var werewolfPlayer = Player(name: "Wolf")
        werewolfPlayer.assignRole(.werewolf)
        
        #expect(werewolfPlayer.canPerformNightAction, "Werewolf should be able to perform night actions")
        #expect(werewolfPlayer.isWerewolf, "Werewolf should be werewolf")
        #expect(!werewolfPlayer.isVillager, "Werewolf should not be villager team")
    }
    
    // MARK: - Player State Management Tests
    
    @Test("Player elimination tracking")
    func playerElimination() {
        var player = Player(name: "Alice")
        
        #expect(player.isAlive, "Player should be alive initially")
        
        player.eliminate()
        #expect(!player.isAlive, "Player should not be alive after elimination")
        #expect(player.eliminationReason != nil, "Elimination reason should be recorded")
    }
    
    @Test("Player voting state management")
    func playerVoting() {
        var player = Player(name: "Alice")
        
        #expect(player.votedFor == nil, "Player should have no vote initially")
        #expect(!player.hasVoted, "Player should not have voted initially")
        
        player.castVote(for: "Bob")
        #expect(player.votedFor == "Bob", "Player should have voted for Bob")
        #expect(player.hasVoted, "Player should have voted")
        
        player.clearVote()
        #expect(player.votedFor == nil, "Vote should be cleared")
        #expect(!player.hasVoted, "Player should not have voted after clearing")
    }
    
    // MARK: - Player Comparison Tests
    
    @Test("Player equality comparison")
    func playerEquality() {
        let player1 = Player(name: "Alice")
        let player2 = Player(name: "Alice")
        let player3 = Player(name: "Bob")
        
        #expect(player1 == player2, "Players with same name should be equal")
        #expect(player1 != player3, "Players with different names should not be equal")
    }
    
    @Test("Player hashable implementation")
    func playerHashable() {
        let player1 = Player(name: "Alice")
        let player2 = Player(name: "Alice")
        let player3 = Player(name: "Bob")
        
        #expect(player1.hashValue == player2.hashValue, "Players with same name should have same hash")
        #expect(player1.hashValue != player3.hashValue, "Players with different names should have different hash")
    }
}

/// Test suite for Role model and role-related functionality
/// Validates role definitions, capabilities, and night action logic
struct RoleModelTests {
    
    // MARK: - Role Definition Tests
    
    @Test("All roles have correct properties")
    func roleProperties() {
        // Test Werewolf
        let werewolf = Role.werewolf
        #expect(werewolf.displayName == "Werewolf", "Werewolf display name should be correct")
        #expect(werewolf.team == .werewolf, "Werewolf should be on werewolf team")
        #expect(werewolf.hasNightAction, "Werewolf should have night action")
        #expect(!werewolf.description.isEmpty, "Werewolf should have description")
        
        // Test Seer
        let seer = Role.seer
        #expect(seer.displayName == "Seer", "Seer display name should be correct")
        #expect(seer.team == .villager, "Seer should be on villager team")
        #expect(seer.hasNightAction, "Seer should have night action")
        
        // Test Doctor
        let doctor = Role.doctor
        #expect(doctor.displayName == "Doctor", "Doctor display name should be correct")
        #expect(doctor.team == .villager, "Doctor should be on villager team")
        #expect(doctor.hasNightAction, "Doctor should have night action")
        
        // Test Villager
        let villager = Role.villager
        #expect(villager.displayName == "Villager", "Villager display name should be correct")
        #expect(villager.team == .villager, "Villager should be on villager team")
        #expect(!villager.hasNightAction, "Villager should not have night action")
    }
    
    @Test("Role team classifications")
    func roleTeamClassifications() {
        let werewolfRoles: [Role] = [.werewolf]
        let villagerRoles: [Role] = [.villager, .seer, .doctor]
        
        for role in werewolfRoles {
            #expect(role.team == .werewolf, "\(role.displayName) should be werewolf team")
            #expect(!role.isVillagerTeam, "\(role.displayName) should not be villager team")
        }
        
        for role in villagerRoles {
            #expect(role.team == .villager, "\(role.displayName) should be villager team")
            #expect(role.isVillagerTeam, "\(role.displayName) should be villager team")
        }
    }
    
    @Test("Night action capabilities")
    func nightActionCapabilities() {
        let nightActionRoles: [Role] = [.werewolf, .seer, .doctor]
        let noNightActionRoles: [Role] = [.villager]
        
        for role in nightActionRoles {
            #expect(role.hasNightAction, "\(role.displayName) should have night action")
            #expect(!role.nightActionDescription.isEmpty, "\(role.displayName) should have action description")
        }
        
        for role in noNightActionRoles {
            #expect(!role.hasNightAction, "\(role.displayName) should not have night action")
        }
    }
    
    // MARK: - Role Action Tests
    
    @Test("Werewolf night action validation")
    func werewolfNightAction() {
        let werewolfRole = Role.werewolf
        let availableTargets = ["Alice", "Bob", "Carol"]
        
        #expect(werewolfRole.canTargetPlayer("Alice", availableTargets: availableTargets), 
               "Werewolf should be able to target available player")
        #expect(!werewolfRole.canTargetPlayer("David", availableTargets: availableTargets), 
               "Werewolf should not be able to target unavailable player")
    }
    
    @Test("Seer night action validation")
    func seerNightAction() {
        let seerRole = Role.seer
        let availableTargets = ["Alice", "Bob", "Carol"]
        
        #expect(seerRole.canTargetPlayer("Bob", availableTargets: availableTargets), 
               "Seer should be able to investigate available player")
        #expect(seerRole.investigationResult(for: .werewolf) == "This player is a Werewolf!", 
               "Seer should detect werewolf correctly")
        #expect(seerRole.investigationResult(for: .villager) == "This player is not a Werewolf.", 
               "Seer should detect villager correctly")
    }
    
    @Test("Doctor night action validation")
    func doctorNightAction() {
        let doctorRole = Role.doctor
        let availableTargets = ["Alice", "Bob", "Carol"]
        
        #expect(doctorRole.canTargetPlayer("Carol", availableTargets: availableTargets), 
               "Doctor should be able to protect available player")
        #expect(doctorRole.canProtectSamePlayerConsecutively == false, 
               "Doctor should not be able to protect same player twice in a row")
    }
    
    // MARK: - Role Balance Tests
    
    @Test("Role distribution validation")
    func roleDistribution() {
        // Test 6-player game distribution
        let sixPlayerDistribution = RoleDistributor.generateRoles(for: 6)
        #expect(sixPlayerDistribution.count == 6, "Should generate exactly 6 roles")
        
        let werewolvesCount = sixPlayerDistribution.filter { $0 == .werewolf }.count
        let seersCount = sixPlayerDistribution.filter { $0 == .seer }.count
        let doctorsCount = sixPlayerDistribution.filter { $0 == .doctor }.count
        let villagersCount = sixPlayerDistribution.filter { $0 == .villager }.count
        
        #expect(werewolvesCount == 2, "6-player game should have 2 werewolves")
        #expect(seersCount == 1, "6-player game should have 1 seer")
        #expect(doctorsCount == 1, "6-player game should have 1 doctor")
        #expect(villagersCount == 2, "6-player game should have 2 villagers")
    }
    
    @Test("Role assignment randomization")
    func roleAssignmentRandomization() {
        let playerNames = ["Alice", "Bob", "Carol", "David", "Eve", "Frank"]
        
        // Generate multiple role assignments to test randomization
        let assignment1 = RoleDistributor.assignRoles(to: playerNames)
        let assignment2 = RoleDistributor.assignRoles(to: playerNames)
        
        // While assignments might occasionally be the same, they should be independent
        #expect(assignment1.count == 6, "First assignment should have 6 players")
        #expect(assignment2.count == 6, "Second assignment should have 6 players")
        
        // Verify role counts are consistent across assignments
        let werewolves1 = assignment1.values.filter { $0 == .werewolf }.count
        let werewolves2 = assignment2.values.filter { $0 == .werewolf }.count
        
        #expect(werewolves1 == 2, "First assignment should have 2 werewolves")
        #expect(werewolves2 == 2, "Second assignment should have 2 werewolves")
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Invalid role operations handled gracefully")
    func invalidRoleOperations() {
        let villagerRole = Role.villager
        
        // Villager should not be able to perform night actions
        #expect(!villagerRole.hasNightAction, "Villager should not have night action")
        
        let result = villagerRole.canTargetPlayer("Anyone", availableTargets: ["Anyone"])
        #expect(!result, "Villager should not be able to target players")
    }
}