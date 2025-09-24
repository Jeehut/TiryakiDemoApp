import SwiftUI

/// Role customization view for adjusting game balance and special roles
/// Allows players to customize role distribution within balanced parameters
struct RoleCustomizationView: View {
    @Environment(GameModel.self) private var gameModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var customRoles: RoleDistributionConfig = RoleDistributionConfig()
    @State private var showingAdvancedOptions: Bool = false
    @State private var useDefaultRoles: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                headerSection
                
                // Default vs Custom toggle
                roleSelectionModeSection
                
                // Role distribution display
                roleDistributionSection
                
                if !useDefaultRoles {
                    // Custom role adjustment
                    customRoleSection
                }
                
                // Advanced options
                if showingAdvancedOptions {
                    advancedOptionsSection
                }
                
                Spacer(minLength: 32)
                
                // Continue button
                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationTitle("Role Setup")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Advanced") {
                    withAnimation(.easeInOut) {
                        showingAdvancedOptions.toggle()
                    }
                }
            }
        }
        .onAppear {
            setupDefaultRoles()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "theatermasks.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)
            
            Text("Choose Roles")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Customize which roles will be in your \(gameModel.players.count)-player game.")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Choose roles for your \(gameModel.players.count) player game")
    }
    
    private var roleSelectionModeSection: some View {
        VStack(spacing: 16) {
            Picker("Role Selection", selection: $useDefaultRoles) {
                Text("Recommended").tag(true)
                Text("Custom").tag(false)
            }
            .pickerStyle(.segmented)
            .font(.title2)
            .accessibilityLabel("Role selection mode")
            
            Text(useDefaultRoles ? 
                 "Use carefully balanced roles for fair gameplay" : 
                 "Customize roles to your preference")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .onChange(of: useDefaultRoles) { _, newValue in
            if newValue {
                setupDefaultRoles()
            }
        }
    }
    
    private var roleDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Role Distribution")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                RoleCountCard(
                    role: .werewolf,
                    count: customRoles.werewolves,
                    isEditable: !useDefaultRoles
                ) { newCount in
                    customRoles.werewolves = newCount
                }
                
                RoleCountCard(
                    role: .seer,
                    count: customRoles.seer,
                    isEditable: !useDefaultRoles
                ) { newCount in
                    customRoles.seer = newCount
                }
                
                RoleCountCard(
                    role: .doctor,
                    count: customRoles.doctor,
                    isEditable: !useDefaultRoles
                ) { newCount in
                    customRoles.doctor = newCount
                }
                
                RoleCountCard(
                    role: .villager,
                    count: customRoles.villagers,
                    isEditable: !useDefaultRoles
                ) { newCount in
                    customRoles.villagers = newCount
                }
            }
            
            // Total validation
            totalValidationSection
        }
    }
    
    private var customRoleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Adjust Roles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + and - buttons to adjust role counts. Keep the game balanced!")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            // Balance indicator
            balanceIndicatorSection
        }
    }
    
    private var totalValidationSection: some View {
        let totalRoles = customRoles.totalRoles
        let playerCount = gameModel.players.count
        let isValid = totalRoles == playerCount
        
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(isValid ? .green : .orange)
            
            Text("Total: \(totalRoles) of \(playerCount) players")
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(isValid ? .green : .orange)
            
            Spacer()
        }
        .accessibilityLabel(isValid ? "Role count valid" : "Role count invalid. Total \(totalRoles) of \(playerCount) players")
    }
    
    private var balanceIndicatorSection: some View {
        let balance = calculateBalance()
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Game Balance")
                .font(.callout)
                .fontWeight(.medium)
            
            HStack {
                Circle()
                    .fill(balance.color)
                    .frame(width: 12, height: 12)
                
                Text(balance.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .accessibilityLabel("Game balance: \(balance.description)")
    }
    
    private var advancedOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Options")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Future: Optional roles, custom rules, etc.
            Text("Additional customization options will be available in future updates.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .italic()
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var continueButton: some View {
        let canContinue = customRoles.totalRoles == gameModel.players.count && calculateBalance().isBalanced
        
        NavigationLink(destination: GameStartView()) {
            Label("Start Game", systemImage: "play.circle.fill")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canContinue ? Color.accentColor : Color.gray)
                )
        }
        .disabled(!canContinue)
        .accessibilityLabel("Start game")
        .accessibilityHint(canContinue ? "Begins the game with selected roles" : "Fix role distribution to continue")
    }
    
    // MARK: - Helper Methods
    
    private func setupDefaultRoles() {
        guard let distribution = GameUtilities.roleDistribution(for: gameModel.players.count) else { return }
        
        customRoles = RoleDistributionConfig(
            werewolves: distribution.werewolves,
            seer: distribution.seer,
            doctor: distribution.doctor,
            villagers: distribution.villagers
        )
    }
    
    private func calculateBalance() -> GameBalance {
        let werewolvesCount = customRoles.werewolves
        let villagerTeamCount = customRoles.seer + customRoles.doctor + customRoles.villagers
        
        if werewolvesCount == 0 {
            return GameBalance(isBalanced: false, description: "No werewolves - villagers auto-win", color: .red)
        }
        
        if villagerTeamCount == 0 {
            return GameBalance(isBalanced: false, description: "No villagers - werewolves auto-win", color: .red)
        }
        
        if werewolvesCount >= villagerTeamCount {
            return GameBalance(isBalanced: false, description: "Too many werewolves - unfair advantage", color: .red)
        }
        
        let ratio = Double(werewolvesCount) / Double(werewolvesCount + villagerTeamCount)
        
        if ratio < 0.2 {
            return GameBalance(isBalanced: true, description: "Villager-favored - easier for village", color: .blue)
        } else if ratio > 0.35 {
            return GameBalance(isBalanced: true, description: "Werewolf-favored - harder for village", color: .orange)
        } else {
            return GameBalance(isBalanced: true, description: "Well balanced - fair for both teams", color: .green)
        }
    }
}

// MARK: - Supporting Views

/// Individual role count card with increment/decrement controls
private struct RoleCountCard: View {
    let role: Role
    let count: Int
    let isEditable: Bool
    let onChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Role header
            VStack(spacing: 4) {
                Image(systemName: role.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(role.themeColor)
                
                Text(role.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            // Count display and controls
            HStack {
                if isEditable {
                    Button {
                        if count > 0 {
                            onChange(count - 1)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(count > 0 ? .red : .gray)
                    }
                    .disabled(count <= 0)
                    .accessibilityLabel("Decrease \(role.displayName) count")
                }
                
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(minWidth: 40)
                
                if isEditable {
                    Button {
                        onChange(count + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }
                    .accessibilityLabel("Increase \(role.displayName) count")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(role.displayName): \(count)")
        .accessibilityValue("\(count) players")
        .accessibilityHint(isEditable ? "Use plus and minus buttons to adjust" : "Role count is set automatically")
    }
}

// MARK: - Supporting Types

private struct RoleDistributionConfig {
    var werewolves: Int = 0
    var seer: Int = 0
    var doctor: Int = 0
    var villagers: Int = 0
    
    var totalRoles: Int {
        werewolves + seer + doctor + villagers
    }
}

private struct GameBalance {
    let isBalanced: Bool
    let description: String
    let color: Color
}

// MARK: - Role Extensions

private extension Role {
    var themeColor: Color {
        switch self {
        case .werewolf:
            return .red
        case .seer:
            return .purple
        case .doctor:
            return .blue
        case .villager:
            return .green
        }
    }
    
    var iconName: String {
        switch self {
        case .werewolf:
            return "moon.fill"
        case .seer:
            return "eye.fill"
        case .doctor:
            return "cross.fill"
        case .villager:
            return "person.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RoleCustomizationView()
    }
    .environment({
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        return gameModel
    }())
}