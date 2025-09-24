import SwiftUI

/// Player setup view for entering player names and validating game requirements
/// Implements group device sharing with large readable text and clear visual hierarchy
struct PlayerSetupView: View {
    @Environment(GameModel.self) private var gameModel
    
    @State private var newPlayerName: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header section
                headerSection
                
                // Player entry section
                playerEntrySection
                
                // Current players list
                if !gameModel.players.isEmpty {
                    currentPlayersSection
                }
                
                Spacer()
                
                // Validation and start section
                validationSection
                
                // Start game button
                startGameButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .navigationTitle("Game Setup")
            .navigationBarTitleDisplayMode(.large)
            .alert("Setup Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)
            
            Text("Add Players")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Enter the names of everyone playing. You'll need \(GameConstants.minimumPlayerCount)-\(GameConstants.maximumPlayerCount) players.")
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Add Players. Enter names of everyone playing. Need \(GameConstants.minimumPlayerCount) to \(GameConstants.maximumPlayerCount) players.")
    }
    
    private var playerEntrySection: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Enter player name", text: $newPlayerName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
                    .submitLabel(.done)
                    .onSubmit {
                        addPlayer()
                    }
                    .accessibilityLabel("Player name input")
                    .accessibilityHint("Enter a player's name, then tap Add Player or press Done")
                
                Button("Add Player") {
                    addPlayer()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel("Add Player")
                .accessibilityHint("Adds the entered name to the player list")
            }
        }
    }
    
    private var currentPlayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Players (\(gameModel.players.count))")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(gameModel.players, id: \.name) { player in
                    PlayerCard(player: player) {
                        removePlayer(player)
                    }
                }
            }
        }
        .accessibilityLabel("Current players list with \(gameModel.players.count) players")
    }
    
    private var validationSection: some View {
        VStack(spacing: 8) {
            let validation = validateCurrentSetup()
            
            HStack {
                Image(systemName: validation.isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(validation.isValid ? .green : .orange)
                    .font(.title2)
                
                Text(validation.message)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(validation.isValid ? .green : .orange)
                
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(validation.isValid ? "Setup valid. \(validation.message)" : "Setup invalid. \(validation.message)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var startGameButton: some View {
        let canStart = validateCurrentSetup().isValid
        
        NavigationLink(destination: RoleCustomizationView()) {
            Label("Continue to Role Setup", systemImage: "arrow.right.circle.fill")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canStart ? Color.accentColor : Color.gray)
                )
        }
        .disabled(!canStart)
        .accessibilityLabel("Continue to role setup")
        .accessibilityHint(canStart ? "Proceeds to role customization" : "Add more players to continue")
    }
    
    // MARK: - Helper Methods
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else { return }
        
        // Validate player name
        guard trimmedName.count <= 50 else {
            showError("Player name is too long (maximum 50 characters)")
            return
        }
        
        guard !gameModel.players.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            showError("A player with this name already exists")
            return
        }
        
        guard gameModel.players.count < GameConstants.maximumPlayerCount else {
            showError("Maximum of \(GameConstants.maximumPlayerCount) players allowed")
            return
        }
        
        // Add player
        gameModel.addPlayers([trimmedName])
        newPlayerName = ""
        
        // Haptic feedback for successful addition
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func removePlayer(_ player: Player) {
        gameModel.players.removeAll { $0.name == player.name }
    }
    
    private func validateCurrentSetup() -> SetupValidation {
        let playerCount = gameModel.players.count
        
        if playerCount < GameConstants.minimumPlayerCount {
            return SetupValidation(
                isValid: false,
                message: "Add \(GameConstants.minimumPlayerCount - playerCount) more player\(GameConstants.minimumPlayerCount - playerCount == 1 ? "" : "s")"
            )
        }
        
        if playerCount > GameConstants.maximumPlayerCount {
            return SetupValidation(
                isValid: false,
                message: "Too many players (maximum \(GameConstants.maximumPlayerCount))"
            )
        }
        
        return SetupValidation(
            isValid: true,
            message: "Ready to start! \(playerCount) player\(playerCount == 1 ? "" : "s")"
        )
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        
        // Haptic feedback for error
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - Supporting Views

/// Individual player card with remove button
private struct PlayerCard: View {
    let player: Player
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(player.name)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer(minLength: 8)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("Remove \(player.name)")
            .accessibilityHint("Removes this player from the game")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player \(player.name)")
        .accessibilityAction(named: "Remove") {
            onRemove()
        }
    }
}

// MARK: - Supporting Types

private struct SetupValidation {
    let isValid: Bool
    let message: String
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlayerSetupView()
    }
    .environment(GameModel())
}