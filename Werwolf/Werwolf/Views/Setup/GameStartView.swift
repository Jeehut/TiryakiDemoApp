import SwiftUI

/// Final game start confirmation view with summary and launch
/// Displays final game configuration and initializes game state
struct GameStartView: View {
    @Environment(GameModel.self) private var gameModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isStarting: Bool = false
    @State private var showingInstructions: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                headerSection
                
                // Game summary
                gameSummarySection
                
                // Role distribution summary
                roleDistributionSection
                
                // Game instructions preview
                instructionsSection
                
                Spacer(minLength: 32)
                
                // Action buttons
                actionButtonsSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationTitle("Ready to Play")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(isStarting)
        .sheet(isPresented: $showingInstructions) {
            GameInstructionsSheet()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)
            
            Text("Ready to Start!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Review your game setup and begin the Werwolf experience.")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ready to start Werwolf game")
    }
    
    private var gameSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Summary")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SummaryRow(
                    icon: "person.3.fill",
                    label: "Players",
                    value: "\(gameModel.players.count)",
                    color: .blue
                )
                
                SummaryRow(
                    icon: "clock.fill",
                    label: "Estimated Time",
                    value: estimatedGameTime,
                    color: .green
                )
                
                SummaryRow(
                    icon: "gamecontroller.fill",
                    label: "Difficulty",
                    value: gameDifficulty,
                    color: .orange
                )
            }
        }
    }
    
    private var roleDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Roles in This Game")
                .font(.title2)
                .fontWeight(.semibold)
            
            let distribution = getCurrentRoleDistribution()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                if distribution.werewolves > 0 {
                    RoleSummaryCard(role: .werewolf, count: distribution.werewolves)
                }
                
                if distribution.seer > 0 {
                    RoleSummaryCard(role: .seer, count: distribution.seer)
                }
                
                if distribution.doctor > 0 {
                    RoleSummaryCard(role: .doctor, count: distribution.doctor)
                }
                
                if distribution.villagers > 0 {
                    RoleSummaryCard(role: .villager, count: distribution.villagers)
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InstructionStep(
                    number: "1",
                    title: "Device Sharing",
                    description: "Everyone gathers around one device placed in the center"
                )
                
                InstructionStep(
                    number: "2",
                    title: "Private Phases",
                    description: "Players pass the device for secret role reveals and actions"
                )
                
                InstructionStep(
                    number: "3",
                    title: "Group Phases",
                    description: "Discussion and elimination happen with device in center"
                )
            }
            
            Button("View Full Instructions") {
                showingInstructions = true
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("View detailed game instructions")
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Start game button
            Button {
                startGame()
            } label: {
                HStack {
                    if isStarting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    
                    Text(isStarting ? "Starting Game..." : "Start Werwolf Game")
                        .fontWeight(.semibold)
                }
                .font(.title2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor)
                )
            }
            .disabled(isStarting)
            .accessibilityLabel("Start Werwolf game")
            .accessibilityHint("Begins the game with current players and roles")
            
            // Back to setup button
            Button("Back to Setup") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .disabled(isStarting)
            .accessibilityLabel("Back to setup")
            .accessibilityHint("Returns to role customization")
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentRoleDistribution() -> (werewolves: Int, seer: Int, doctor: Int, villagers: Int) {
        return GameUtilities.roleDistribution(for: gameModel.players.count) ?? (0, 0, 0, 0)
    }
    
    private var estimatedGameTime: String {
        let playerCount = gameModel.players.count
        let baseTime = 20 // Base time in minutes
        let timePerPlayer = 3 // Additional minutes per player
        let totalMinutes = baseTime + (playerCount * timePerPlayer)
        
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(totalMinutes)m"
        }
    }
    
    private var gameDifficulty: String {
        let playerCount = gameModel.players.count
        let distribution = getCurrentRoleDistribution()
        let werewolfRatio = Double(distribution.werewolves) / Double(playerCount)
        
        if playerCount <= 4 {
            return "Beginner"
        } else if werewolfRatio > 0.33 {
            return "Hard"
        } else if werewolfRatio < 0.25 {
            return "Easy"
        } else {
            return "Medium"
        }
    }
    
    private func startGame() {
        isStarting = true
        
        // Add a small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = gameModel.startGame()
            
            if success {
                // Haptic feedback for game start
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                // Navigation will be handled by the parent view
                // observing gameModel.isGameActive
            } else {
                // Handle error
                isStarting = false
                // Could show error alert here
            }
        }
    }
}

// MARK: - Supporting Views

/// Summary row for game information
private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

/// Role summary card showing role and count
private struct RoleSummaryCard: View {
    let role: Role
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: role.iconName)
                .font(.title2)
                .foregroundStyle(role.themeColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(role.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("\(count) player\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(count) \(role.displayName)\(count == 1 ? "" : "s")")
    }
}

/// Instruction step with number and description
private struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number): \(title). \(description)")
    }
}

/// Game instructions sheet
private struct GameInstructionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Play Werwolf")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Werwolf is a social deduction game where villagers try to find and eliminate the werewolves among them, while werewolves try to eliminate all villagers.")
                        .font(.body)
                    
                    // Add more detailed instructions here
                    Text("Detailed instructions would go here...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
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
        GameStartView()
    }
    .environment({
        let gameModel = GameModel()
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
        return gameModel
    }())
}