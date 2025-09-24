import Testing
import Foundation
@testable import Werwolf

/// Additional dedicated test suite for Role model edge cases and complex scenarios
/// Separated from PlayerModelTests for better organization and focus
struct RoleModelTests {
    
    // MARK: - Role Enum Tests
    
    @Test("Role enum completeness")
    func roleEnumCompleteness() {
        let allRoles = Role.allCases
        let expectedRoles: [Role] = [.werewolf, .seer, .doctor, .villager]
        
        #expect(allRoles.count == expectedRoles.count, "All expected roles should be defined")
        
        for expectedRole in expectedRoles {
            #expect(allRoles.contains(expectedRole), "Role \(expectedRole) should be included")
        }
    }
    
    @Test("Role identifiable implementation")
    func roleIdentifiable() {
        let werewolf = Role.werewolf
        let seer = Role.seer
        
        #expect(werewolf.id == werewolf.rawValue, "Role ID should match raw value")
        #expect(seer.id != werewolf.id, "Different roles should have different IDs")
    }
    
    // MARK: - Role Win Condition Tests
    
    @Test("Role win conditions")
    func roleWinConditions() {
        let werewolf = Role.werewolf
        let villager = Role.villager
        let seer = Role.seer
        let doctor = Role.doctor
        
        // Werewolf win condition
        #expect(werewolf.winsWhenWerewolvesEqual, "Werewolf wins when werewolves equal villagers")
        #expect(!werewolf.winsWhenNoWerewolves, "Werewolf does not win when no werewolves")
        
        // Villager team win conditions
        let villagerTeam = [villager, seer, doctor]
        for role in villagerTeam {
            #expect(!role.winsWhenWerewolvesEqual, "Villager team does not win when werewolves equal")
            #expect(role.winsWhenNoWerewolves, "Villager team wins when no werewolves")
        }
    }
    
    // MARK: - Role Priority Tests
    
    @Test("Night action priority order")
    func nightActionPriority() {
        let roles = [Role.seer, Role.werewolf, Role.doctor]
        let sortedRoles = roles.sorted { $0.nightActionPriority < $1.nightActionPriority }
        
        // Expected order: Seer -> Werewolf -> Doctor
        #expect(sortedRoles[0] == .seer, "Seer should act first")
        #expect(sortedRoles[1] == .werewolf, "Werewolf should act second")
        #expect(sortedRoles[2] == .doctor, "Doctor should act last")
    }
    
    @Test("Role action timing validation")
    func roleActionTiming() {
        let seer = Role.seer
        let werewolf = Role.werewolf
        let doctor = Role.doctor
        
        #expect(seer.actionTiming == .investigation, "Seer performs investigation")
        #expect(werewolf.actionTiming == .elimination, "Werewolf performs elimination")
        #expect(doctor.actionTiming == .protection, "Doctor performs protection")
    }
    
    // MARK: - Special Role Ability Tests
    
    @Test("Doctor consecutive protection rules")
    func doctorConsecutiveProtection() {
        let doctor = Role.doctor
        
        // Doctor cannot protect the same player two nights in a row
        #expect(!doctor.canProtectSamePlayerConsecutively, "Doctor cannot protect same player consecutively")
        
        let protectionHistory = ["Alice", "Bob", "Alice"]
        let canProtectAlice = doctor.canProtectPlayer("Alice", given: protectionHistory)
        #expect(canProtectAlice, "Doctor can protect Alice again after protecting someone else")
        
        let recentHistory = ["Alice"]
        let canProtectAliceAgain = doctor.canProtectPlayer("Alice", given: recentHistory)
        #expect(!canProtectAliceAgain, "Doctor cannot protect Alice immediately after")
    }
    
    @Test("Seer investigation accuracy")
    func seerInvestigationAccuracy() {
        let seer = Role.seer
        
        // Seer should accurately identify werewolves
        let werewolfResult = seer.investigationResult(for: .werewolf)
        #expect(werewolfResult.contains("Werewolf"), "Seer should identify werewolves")
        
        // Seer should identify all other roles as "not werewolf"
        let villagerResult = seer.investigationResult(for: .villager)
        let doctorResult = seer.investigationResult(for: .doctor)
        
        #expect(villagerResult.contains("not"), "Villager should be identified as not werewolf")
        #expect(doctorResult.contains("not"), "Doctor should be identified as not werewolf")
    }
    
    @Test("Werewolf collective action")
    func werewolfCollectiveAction() {
        let werewolf = Role.werewolf
        
        #expect(werewolf.requiresConsensus, "Werewolves should require consensus for elimination")
        #expect(werewolf.canSeeOtherWerewolves, "Werewolves should see other werewolves")
        #expect(werewolf.immuneToNightElimination, "Werewolves should be immune to their own elimination")
    }
    
    // MARK: - Role Description and UI Tests
    
    @Test("Role descriptions completeness")
    func roleDescriptions() {
        for role in Role.allCases {
            #expect(!role.description.isEmpty, "\(role.displayName) should have description")
            #expect(!role.displayName.isEmpty, "\(role.displayName) should have display name")
            #expect(role.description.count > 10, "\(role.displayName) description should be meaningful")
        }
    }
    
    @Test("Role instruction text for device passing")
    func roleInstructionText() {
        let werewolf = Role.werewolf
        let seer = Role.seer
        let doctor = Role.doctor
        
        let werewolfInstructions = werewolf.devicePassingInstructions()
        #expect(werewolfInstructions.contains("choose"), "Werewolf instructions should mention choosing")
        #expect(werewolfInstructions.contains("eliminate"), "Werewolf instructions should mention elimination")
        
        let seerInstructions = seer.devicePassingInstructions()
        #expect(seerInstructions.contains("investigate"), "Seer instructions should mention investigation")
        
        let doctorInstructions = doctor.devicePassingInstructions()
        #expect(doctorInstructions.contains("protect"), "Doctor instructions should mention protection")
    }
    
    // MARK: - Role Balance Validation Tests
    
    @Test("Role balance mathematical validation")
    func roleBalanceValidation() {
        // Test various player counts for balance
        let testCounts = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        
        for playerCount in testCounts {
            let roles = RoleDistributor.generateRoles(for: playerCount)
            #expect(roles.count == playerCount, "Should generate exactly \(playerCount) roles")
            
            let werewolfCount = roles.filter { $0 == .werewolf }.count
            let villagerTeamCount = roles.filter { $0.isVillagerTeam }.count
            
            // Werewolves should never equal or exceed villagers at start
            #expect(werewolfCount < villagerTeamCount, "Werewolves should be outnumbered initially for \(playerCount) players")
            
            // Werewolves should be roughly 25-33% of total
            let werewolfRatio = Double(werewolfCount) / Double(playerCount)
            #expect(werewolfRatio >= 0.2 && werewolfRatio <= 0.4, "Werewolf ratio should be balanced for \(playerCount) players")
        }
    }
    
    @Test("Minimum game viability")
    func minimumGameViability() {
        // 3 players is minimum - should have meaningful roles
        let threePlayerRoles = RoleDistributor.generateRoles(for: 3)
        let werewolfCount = threePlayerRoles.filter { $0 == .werewolf }.count
        let specialRoleCount = threePlayerRoles.filter { $0 == .seer || $0 == .doctor }.count
        
        #expect(werewolfCount >= 1, "3-player game should have at least 1 werewolf")
        #expect(specialRoleCount >= 1, "3-player game should have at least 1 special role")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Invalid player count role generation")
    func invalidPlayerCountRoleGeneration() {
        // Test below minimum
        let tooFewRoles = RoleDistributor.generateRoles(for: 2)
        #expect(tooFewRoles.isEmpty, "Should not generate roles for too few players")
        
        // Test above maximum
        let tooManyRoles = RoleDistributor.generateRoles(for: 15)
        #expect(tooManyRoles.isEmpty, "Should not generate roles for too many players")
        
        // Test zero/negative
        let zeroRoles = RoleDistributor.generateRoles(for: 0)
        let negativeRoles = RoleDistributor.generateRoles(for: -1)
        
        #expect(zeroRoles.isEmpty, "Should not generate roles for zero players")
        #expect(negativeRoles.isEmpty, "Should not generate roles for negative players")
    }
}