# Technical Architecture: WerwolfGame

**Created**: September 21, 2025
**Status**: Technical Plan
**Prerequisites**: Completed business specification (Spec.md) and technical research (Research.md)

## System Overview

### High-Level Architecture
WerwolfGame implements a pure SwiftUI architecture with @Observable state management for shared-device social gaming. Central GameModel manages all game state with environment injection providing access across the view hierarchy. Privacy-sensitive information is handled through role-based computed properties and privacySensitive() view modifiers for secure device passing.

### Core Components
- **GameModel**: @Observable central state manager containing players, roles, current phase, and game logic with private information protection
- **Game Views**: SwiftUI view hierarchy for setup, gameplay phases, voting, and results with accessibility-first design
- **Role System**: Enumeration-based role definitions with capabilities, win conditions, and night action logic
- **Device Passing Interface**: Custom UI patterns with VoiceOver focus management and privacy protection during player transitions

### Data Flow
Unidirectional data flow with GameModel as single source of truth. User actions flow up through view callbacks to GameModel methods, state changes automatically trigger SwiftUI view updates. Private information (roles, votes) accessed through computed properties that filter data based on current player context. No persistence required - all game data exists in memory during active session only.

## iOS/macOS Implementation Details

### SwiftUI Structure

**View Hierarchy**:
```
GameStateView (main game coordinator)
├── Setup/
│   ├── PlayerSetupView (player name entry and validation)
│   ├── RoleCustomizationView (optional role selection interface)
│   └── GameStartView (final setup confirmation and game launch)
├── Game/
│   ├── NightPhaseView (werewolf, seer, doctor night actions)
│   ├── DayPhaseView (discussion phase with player status)
│   ├── RoleRevealView (private role display with privacySensitive)
│   └── VotingView (secret ballot interface with vote tallying)
├── Results/
│   ├── EliminationView (dramatic player elimination reveal)
│   └── GameResultsView (win/loss screen with celebration)
└── Components/
    ├── PlayerListView (reusable player display component)
    ├── GameProgressView (phase indicator and game status)
    └── DeviceHandoffView (secure device passing interface)
```

**State Management**:
- **ViewModels**: Single @Observable GameModel injected via environment, no separate view models needed
- **Data Binding**: Direct binding to GameModel properties with computed properties for filtered information
- **Navigation**: NavigationStack with programmatic navigation based on game phase transitions

**Architectural Decision Rationale**:
- **Why this structure**: Follows SwiftUI Guidelines for component organization, separates concerns by game phase, maintains accessibility focus
- **Alternatives considered**: Multiple view models per phase (rejected - adds complexity), GameplayKit state machine (evaluated - may be overkill for turn-based flow)
- **Trade-offs**: Simple structure aids accessibility but requires careful state design for complex game logic

### Data Layer Design

**Storage Strategy**: In-memory only (no persistence required per specification)

**Model Architecture**:
```swift
// Primary entities (conceptual - detailed implementation in Steps phase)
@Observable
class GameModel {
    var players: [Player] = []
    var currentPhase: GamePhase = .setup
    var currentRound: Int = 1
    var gameSettings: GameSettings = GameSettings()
    
    @ObservationIgnored
    private var playerRoles: [PlayerID: Role] = [:]
    @ObservationIgnored
    private var nightActions: [NightAction] = []
    @ObservationIgnored
    private var votes: [PlayerID: PlayerID] = [:]
}

struct Player: Identifiable {
    let id: UUID
    var name: String
    var isEliminated: Bool
    var eliminationRound: Int?
}

enum GamePhase: CaseIterable {
    case setup, night, day, voting, elimination, gameOver
}

enum Role: String, CaseIterable {
    case villager, werewolf, seer, doctor, hunter, cupid, mayor
}
```

**Data Access Pattern**: Direct property access with role-based computed properties for privacy filtering
**Synchronization Strategy**: Not applicable - single device, no sync required

**Decision Rationale**:
- **Why this storage approach**: Ephemeral games per specification requirements, eliminates privacy concerns, simplifies architecture
- **Performance characteristics**: Optimal - all data in memory, no I/O overhead, instant state changes
- **Scalability considerations**: Memory usage scales linearly with player count (max 12 players = minimal impact)

### Service Layer Architecture

**Service Organization**:
- **GameLogicService**: Embedded within GameModel - handles role assignment, win condition detection, vote tallying
- **GameRulesEngine**: Static utility for game balance validation, role combinations, and rule enforcement
- **AccessibilityService**: SwiftUI native accessibility with custom focus management for device handoff

**External Integration Strategy**:
- **APIs**: None required - fully offline game design
- **Authentication**: Not applicable - local gameplay only
- **Error Handling**: Swift Result types for game logic validation, minimal error scenarios expected

**Dependency Management**:
- **Package Dependencies**: None - pure SwiftUI/Foundation implementation
- **Version Requirements**: iOS 17+ for @Observable support (aligns with project iOS 26.0+ target)
- **Integration Points**: Native SwiftUI accessibility APIs, no external service integration

### Platform-Specific Considerations

#### iOS Implementation
- **Minimum iOS Version**: iOS 17+ (justified by @Observable support requirement)
- **Device Support**: iPhone, iPad optimized - shared device design benefits from larger iPad screens for group visibility
- **Performance Targets**:
  - App launch impact: Minimal - no heavy initialization, immediate game setup available
  - Memory usage: <10MB for maximum 12-player games with full state
  - UI responsiveness: 60fps maintained during phase transitions and voting animations

#### macOS Implementation (if applicable)
- **Minimum macOS Version**: macOS 14+ (for @Observable support)
- **Mac-Specific Features**: Larger screen estate ideal for bigger player groups, mouse/keyboard navigation support
- **Menu Integration**: Standard game controls in menu bar - New Game, Settings, Help

#### App Store Compliance
- **Privacy Manifest Updates**: None required - no network access, no data collection
- **New Permissions Required**: None - fully self-contained game
- **Review Guidelines Considerations**: Social gaming category, family-friendly content, no in-app purchases or external links

## Implementation Complexity Assessment

### Technical Complexity Assessment
**Complexity Level**: Moderate (manageable with careful state design and accessibility testing)

**Implementation Challenges**:
- **Setup and Infrastructure**: Low complexity - clean slate SwiftUI project with standard architecture
- **Core Implementation**: Medium complexity - game logic straightforward, device sharing patterns require custom design
- **Integration Points**: Low complexity - no external services, pure SwiftUI implementation
- **Testing Requirements**: Medium complexity - comprehensive game logic testing, extensive accessibility validation

**Risk Assessment**:
- **High Risk Areas**: Shared device accessibility patterns (custom implementation needed), privacy information leakage through VoiceOver
- **Mitigation Strategies**: Early accessibility testing with real users, privacySensitive() modifier validation, comprehensive state testing
- **Unknowns Requiring Research**: None identified - research phase addressed all technical uncertainties

### Dependency Analysis

**External Dependencies**:
- **Swift Packages**: None required - pure SwiftUI implementation
- **iOS Frameworks**: SwiftUI, Foundation (built-in), Accessibility framework (automatic)
- **Third-Party Services**: None - fully offline architecture

**Internal Dependencies**:
- **Existing Code Modifications**: ContentView.swift replacement with game navigation entry point
- **New Shared Components**: Complete game architecture following Swift Guidelines directory structure  
- **Breaking Changes**: None - clean feature addition to existing project

### Quality Assurance Requirements

**Testing Strategy**:
- **Unit Tests**: Swift Testing framework for game logic (role assignment, win conditions, vote tallying, game balance validation)
- **Integration Tests**: GameModel state transition testing, privacy information filtering validation
- **UI Tests**: None - per SwiftUI Guidelines, focus on manual accessibility testing instead

**Validation Requirements**:
- **Context/Guidelines Validation**: Accessibility-first design validation, privacy-by-design verification, SwiftUI best practices compliance
- **Performance Testing**: Memory usage validation with maximum player counts, UI responsiveness during animations
- **Platform Testing**: iPhone/iPad screen size optimization, VoiceOver navigation across device sizes, Dynamic Type scaling validation

## Technical Clarifications

### Areas Requiring Resolution
No significant technical uncertainties remain after comprehensive research phase. All core technologies and architectural patterns have been validated.

### Research Requirements
**Technology Investigations**: Complete - SwiftUI patterns, @Observable state management, and accessibility approaches fully researched

**Proof of Concept Needs**: 
- **Device Handoff UX Testing**: Early prototype of device passing flow with VoiceOver to validate user experience
- **Complex Game State Testing**: Validate @Observable performance with maximum player counts and rapid state changes

---

**Next Phase**: After this technical architecture is approved, proceed to `/ctxk:plan:3-steps` for implementation task breakdown and development planning.

