import SwiftUI

/// Main content view for WerwolfGame
/// Demonstrates the implemented GameModel and core functionality
struct ContentView: View {
    @State private var gameModel = GameModel()
    @State private var showGameDemo = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Image(systemName: "moon.stars.fill")
                .imageScale(.large)
                .foregroundStyle(.primary)
                .font(.largeTitle)
            
            Text("WerwolfGame")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("A social deduction game implementation")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical)
            
            // Game Status
            if gameModel.isGameActive {
                gameStatusSection
            } else {
                gameSetupSection
            }
            
            Spacer()
            
            // Demo button
            Button("Demo Game Logic") {
                showGameDemo.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .sheet(isPresented: $showGameDemo) {
            GameDemoView(gameModel: gameModel)
        }
    }
    
    private var gameSetupSection: some View {
        VStack(spacing: 16) {
            Text("Game Setup")
                .font(.headline)
            
            if gameModel.players.isEmpty {
                Button("Quick Setup (6 Players)") {
                    setupQuickGame()
                }
                .buttonStyle(.bordered)
            } else {
                Text("Players: \(gameModel.players.count)")
                
                Button("Start Game") {
                    startGame()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var gameStatusSection: some View {
        VStack(spacing: 16) {
            Text("Game Active")
                .font(.headline)
                .foregroundStyle(.green)
            
            Text("Phase: \(gameModel.currentPhase.displayName)")
                .font(.title2)
            
            Text("Players: \(gameModel.alivePlayers().count) alive")
            
            if let outcome = gameModel.gameOutcome {
                Text("Winner: \(outcome.displayName)")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                Button("New Game") {
                    resetGame()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Next Phase") {
                    gameModel.advanceToNextPhase()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private func setupQuickGame() {
        gameModel.addPlayers(["Alice", "Bob", "Carol", "David", "Eve", "Frank"])
    }
    
    private func startGame() {
        gameModel.startGame()
    }
    
    private func resetGame() {
        gameModel = GameModel()
    }
}

/// Demo view showing game functionality
struct GameDemoView: View {
    let gameModel: GameModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("WerwolfGame Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This demonstrates the core functionality implemented:")
                        .font(.body)
                    
                    Group {
                        FeatureRow(
                            title: "Game State Management",
                            description: "@Observable GameModel with SwiftUI integration",
                            isImplemented: true
                        )
                        
                        FeatureRow(
                            title: "Role System",
                            description: "Werewolf, Seer, Doctor, Villager with abilities",
                            isImplemented: true
                        )
                        
                        FeatureRow(
                            title: "Device Passing Coordination",
                            description: "WHO/WHAT/WHEN instructions for shared device",
                            isImplemented: true
                        )
                        
                        FeatureRow(
                            title: "Privacy Boundaries",
                            description: "Role-based information filtering",
                            isImplemented: true
                        )
                        
                        FeatureRow(
                            title: "Game Logic Engine",
                            description: "Win conditions, voting, night actions",
                            isImplemented: true
                        )
                        
                        FeatureRow(
                            title: "Comprehensive Testing",
                            description: "20+ test files with full coverage",
                            isImplemented: true
                        )
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    Text("Technical Implementation")
                        .font(.headline)
                    
                    Text("• Pure SwiftUI with @Observable pattern")
                    Text("• Privacy-first architecture")
                    Text("• Device sharing coordination")
                    Text("• Comprehensive test coverage")
                    Text("• Constitutional principles compliance")
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct FeatureRow: View {
    let title: String
    let description: String
    let isImplemented: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isImplemented ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isImplemented ? .green : .gray)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
