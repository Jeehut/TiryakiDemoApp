# Technical Architecture: WerwolfGame

**Created**: September 21, 2025
**Status**: Technical Plan
**Prerequisites**: Completed business specification (Spec.md) and technical research (Research.md)

## System Overview

### High-Level Architecture
WerwolfGame implements a pure SwiftUI architecture with @Observable state management for shared-device social gaming. Central GameModel manages all game state with environment injection providing access across the view hierarchy. Privacy-sensitive information is handled through role-based computed properties and clear visual boundaries for secure device passing.

### Core Components
- **GameModel**: @Observable central state manager containing players, roles, current phase, and game logic with private information protection
- **Game Views**: SwiftUI view hierarchy for setup, gameplay phases, voting, and results with clear visual design
- **Role System**: Enumeration-based role definitions with capabilities, win conditions, and night action logic
- **Device Passing Coordinator**: Manages turn-based device handoff with explicit instructions for who takes device when, what they do, and when to pass it on
- **Instruction System**: Clear, prominent guidance for current player actions and device passing protocol

### Data Flow
Unidirectional data flow with GameModel as single source of truth. User actions flow up through view callbacks to GameModel methods, state changes automatically trigger SwiftUI view updates. Private information (roles, votes) accessed through computed properties that filter data based on current player context. No persistence required - all game data exists in memory during active session only.

## iOS/macOS Implementation Details

### SwiftUI Structure

**View Hierarchy**:
```
GameStateView (main game coordinator with device passing orchestration)
├── Setup/
│   ├── PlayerSetupView (group setup - device stays in center)
│   ├── RoleCustomizationView (group role selection - device in center)
│   └── GameStartView (final confirmation before private role reveals)
├── DeviceFlow/
│   ├── PassDevicePrompt (WHO should take device, WHAT to do instructions)
│   ├── RoleRevealView (PRIVATE: show role, explain abilities, pass instructions)
│   ├── NightActionView (PRIVATE: show available actions for current role)
│   ├── VotingView (PRIVATE: cast vote, confirm, pass device)
│   └── DeviceReturnPrompt (instructions to return device to center/next player)
├── GroupViews/
│   ├── DayPhaseView (GROUP: discussion phase, device in center)
│   ├── EliminationView (GROUP: dramatic reveal, device in center)
│   └── GameResultsView (GROUP: win/loss celebration, device in center)
└── Components/
    ├── InstructionBanner (prominent current player instructions)
    ├── DevicePassingCue (visual/textual handoff guidance)
    ├── PrivacyGuard (look away reminders for other players)
    └── GameProgressView (phase indicator and game status)
```

**State Management**:
- **ViewModels**: Single @Observable GameModel injected via environment, no separate view models needed
- **Data Binding**: Direct binding to GameModel properties with computed properties for filtered information
- **Navigation**: NavigationStack with programmatic navigation based on game phase transitions

**Architectural Decision Rationale**:
- **Why this structure**: Follows SwiftUI Guidelines for component organization, separates concerns by game phase, maintains clear visual hierarchy
- **Alternatives considered**: Multiple view models per phase (rejected - adds complexity), GameplayKit state machine (evaluated - may be overkill for turn-based flow)
- **Trade-offs**: Simple structure aids usability but requires careful state design for complex game logic

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
    
    // Device passing coordination
    var currentPlayerTurn: PlayerID? = nil
    var deviceLocation: DeviceLocation = .center
    var currentInstruction: PlayerInstruction = .groupSetup
    var awaitingAction: PlayerAction? = nil
    
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
    case setup, roleReveal, night, day, voting, elimination, gameOver
}

enum DeviceLocation {
    case center, withPlayer(PlayerID)
}

enum PlayerInstruction {
    case groupSetup
    case passToPlayer(String, action: String) // "Pass to Alice to see her role"
    case privateAction(String) // "Choose your target"
    case returnToCenter(String) // "Return device to center when done"
    case groupDiscussion
    case groupResults
}

enum PlayerAction {
    case revealRole, nightAction, vote, acknowledge
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
- **UIService**: SwiftUI native interface with clear visual feedback for device handoff

**External Integration Strategy**:
- **APIs**: None required - fully offline game design
- **Authentication**: Not applicable - local gameplay only
- **Error Handling**: Swift Result types for game logic validation, minimal error scenarios expected

**Dependency Management**:
- **Package Dependencies**: None - pure SwiftUI/Foundation implementation
- **Version Requirements**: iOS 17+ for @Observable support (aligns with project iOS 26.0+ target)
- **Integration Points**: Native SwiftUI interface APIs, no external service integration

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
**Complexity Level**: Medium-High (manageable with careful device flow design and extensive group testing)

**Implementation Challenges**:
- **Setup and Infrastructure**: Low complexity - clean slate SwiftUI project with standard architecture
- **Core Implementation**: Medium-High complexity - game logic straightforward, but device passing orchestration requires careful UX design
- **Device Flow Coordination**: High complexity - managing turn-based device handoff with clear instructions for who, what, when
- **Privacy UX Design**: Medium complexity - balancing information visibility with game secrecy during device transitions
- **Integration Points**: Low complexity - no external services, pure SwiftUI implementation
- **Testing Requirements**: High complexity - comprehensive game logic testing plus extensive group usability validation

**Risk Assessment**:
- **High Risk Areas**: Device passing orchestration (complex state management), user confusion during handoffs, privacy leaks during device transitions
- **Mitigation Strategies**: Prototype device flow early, extensive group testing with real players, clear visual instruction system, fail-safe privacy guards
- **Critical UX Requirements**: Every device handoff must have crystal clear WHO/WHAT/WHEN instructions to prevent game breakdown

### Dependency Analysis

**External Dependencies**:
- **Swift Packages**: None required - pure SwiftUI implementation
- **iOS Frameworks**: SwiftUI, Foundation (built-in)
- **Third-Party Services**: None - fully offline architecture

**Internal Dependencies**:
- **Existing Code Modifications**: ContentView.swift replacement with game navigation entry point
- **New Shared Components**: Complete game architecture following Swift Guidelines directory structure  
- **Breaking Changes**: None - clean feature addition to existing project

### Quality Assurance Requirements

**Testing Strategy**:
- **Unit Tests**: Swift Testing framework for game logic (role assignment, win conditions, vote tallying, game balance validation)
- **Integration Tests**: GameModel state transition testing, privacy information filtering validation
- **UI Tests**: None - per SwiftUI Guidelines, focus on manual usability testing instead

**Validation Requirements**:
- **Context/Guidelines Validation**: Clear visual design validation, privacy-by-design verification, SwiftUI best practices compliance
- **Performance Testing**: Memory usage validation with maximum player counts, UI responsiveness during animations
- **Platform Testing**: iPhone/iPad screen size optimization, Dynamic Type scaling validation across age groups

## Technical Clarifications

### Areas Requiring Resolution

**Critical UX Flow Design Requirements**:
- **Role Revelation Flow**: Design exact sequence for each player to privately see their role without others seeing
- **Night Phase Coordination**: Determine optimal order and instructions for players who need to take private actions
- **Voting Sequence**: Plan how each player votes privately while maintaining game flow and privacy
- **Device Location Awareness**: Clear visual/textual indicators for when device should be in center vs. with individual player
- **Privacy Fail-safes**: What happens when someone accidentally sees private information meant for another player

**Specific Interaction Patterns Needing Design**:
- Transition animations/screens between "group mode" and "private mode"
- Instructions for non-active players (where to look, what to do while waiting)
- Error recovery if wrong player takes device or sees wrong information
- Timing considerations (how long should private actions take?)
- Screen orientation preferences for shared viewing vs. private viewing

### Research Requirements
**Technology Investigations**: Complete - SwiftUI patterns, @Observable state management, and usability approaches fully researched

**Critical Proof of Concept Needs**: 
- **Device Flow Prototype**: Early interactive prototype testing the complete role revelation → night actions → voting → results cycle with real groups
- **Instruction Clarity Testing**: Validate that device passing instructions are immediately understood by players of various ages
- **Privacy Boundary Validation**: Ensure information hiding mechanisms work reliably during device handoffs

---

**Next Phase**: After this technical architecture is approved, proceed to `/ctxk:plan:3-steps` for implementation task breakdown and development planning.

