# Technical Research: WerwolfGame

**Created**: September 21, 2025
**Status**: Research Complete
**Prerequisites**: Completed business specification (Spec.md)

## Research Overview

### Research Scope
Comprehensive analysis covering SwiftUI game development patterns, game state management architectures, accessibility for shared device usage, and integration requirements within the existing Werwolf iOS project. Research focused on Apple platform technologies with emphasis on modern iOS development practices for turn-based social games.

### Key Findings Summary
SwiftUI ecosystem (iOS 16+) provides robust native support for all Werwolf game requirements. Key insights: @Observable pattern optimal for game state, GameplayKit state machines ideal for phase management, privacySensitive() modifier enables secure device sharing, and comprehensive accessibility APIs support inclusive group gaming. No external dependencies required - pure SwiftUI implementation recommended.

## Codebase Integration Analysis

### Existing Architecture Patterns
Clean slate SwiftUI project with minimal foundation. Current patterns: 4-space indentation, SwiftUI-first approach with @Observable state management, MVVM architecture, and standard Xcode project structure. Project configured for universal iOS/macOS deployment (iOS 26.0+, macOS 26.0+) with no external dependencies.

### Related Existing Components
**Models**: No existing game models - clean implementation required
**Views**: ContentView.swift placeholder for game navigation entry point, WerwolfApp.swift standard SwiftUI app structure 
**Services**: No existing business logic - pure game logic implementation needed
**Navigation**: No established navigation patterns - opportunity to implement NavigationStack best practices

### Integration Requirements
**Files to Modify**: 
- `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/ContentView.swift` - Replace with game navigation
**New Files to Create**: Complete directory structure following Swift Guidelines:
- `Models/` - GameModel, PlayerModel, RoleModel, GamePhaseModel
- `Views/Setup/` - PlayerSetupView, RoleCustomizationView, GameStartView
- `Views/Game/` - GameStateView, NightPhaseView, DayPhaseView, RoleRevealView, VotingView
- `Views/Results/` - GameResultsView, EliminationView
- `Views/Components/` - PlayerListView, GameTimerView, GameProgressView
- `Extensions/` - ArrayExt, GameModelExt
- `Global/` - GameConstants, GameUtilities

**API Integration Points**: None - fully self-contained game implementation
**Data Flow**: Unidirectional with @Observable GameModel injected via environment, flowing down to all views

### Implementation Considerations
**Consistency Requirements**: Follow Context/Guidelines/Swift.md and SwiftUI.md patterns - @Observable state management, 4-space indentation, descriptive naming, SwiftUI-first architecture
**Potential Conflicts**: None identified - clean slate project
**Refactoring Needs**: None required - new feature implementation
**Testing Integration**: Implement Swift Testing framework for game logic, manual accessibility testing for shared device scenarios

## Technology Research

### SwiftUI Game Development Framework
**Version Researched**: iOS 16+ with latest 2024-2025 enhancements
**Documentation Source**: developer.apple.com (primary), wwdcnotes.com (WWDC summaries)
**Last Updated**: September 2025 (iOS 18+ features)
**Research Date**: September 21, 2025
**Community Sources**: swiftbysundell.com, avanderlee.com, hackingwithswift.com, swiftwithmajid.com, fatbobman.com

**Key Capabilities**:
- NavigationStack and NavigationSplitView for turn-based game flow (iOS 16+)
- @Observable macro for optimal game state management with selective updates
- privacySensitive() modifier for secure role revelation and voting interfaces
- Automatic accessibility element creation with VoiceOver integration
- Built-in performance optimizations for complex state management

**Limitations**:
- Device sharing patterns require custom implementation (no built-in support)
- Complex game logic testing requires separate business logic layer
- Large player counts (10-12) may need performance optimization

**Best Practices**:
- Use @Observable over ObservableObject for better performance
- Implement privacySensitive() for all secret information displays
- Apply proper accessibility labels and focus management for shared devices
- Separate game logic from views for comprehensive testing coverage

**Decision Rationale**: SwiftUI provides all required capabilities natively without external dependencies, aligns with project's constitutional principles, and offers optimal user experience for shared device gaming.

### GameplayKit State Management
**Version Researched**: Current iOS SDK (unchanged from iOS 16+)
**Documentation Source**: developer.apple.com/documentation/gameplaykit
**Last Updated**: Stable API, last major updates iOS 16
**Research Date**: September 21, 2025
**Community Sources**: Apple sample code, game development community articles

**Key Capabilities**:
- GKStateMachine for managing game phases (setup, day, night, voting, results)
- Built-in state transition validation and rules enforcement
- Integration with update loops for real-time game state management
- Type-safe state management with enum-based phase definitions

**Limitations**:
- Requires additional learning curve beyond basic SwiftUI state management
- May be overkill for simpler turn-based games
- Limited documentation for complex social game scenarios

**Best Practices**:
- Define clear state transition rules between game phases
- Combine with @Observable for UI reactivity
- Use for complex games with multiple interconnected phases

**Decision Rationale**: GameplayKit provides robust, tested state machine implementation ideal for Werwolf's complex phase management, but evaluation needed against simpler @Observable approach.

## API & Service Research

### No External APIs Required
**Research Date**: September 21, 2025
**Decision Rationale**: Based on specification requirements, WerwolfGame is designed as a fully offline, local multiplayer experience with no network dependencies.

**Key Design Decisions**:
- **Local-only gameplay**: All game data stored in device memory during active sessions
- **No user accounts**: Players identified by names entered at game start only
- **No data persistence**: Games are ephemeral with no history tracking
- **Privacy by design**: No external data transmission eliminates privacy concerns
- **Offline reliability**: No network requirements ensure consistent experience

**Benefits of API-free Architecture**:
- Simplified implementation and maintenance
- Enhanced privacy and security
- Consistent performance regardless of network conditions
- Reduced complexity and external dependencies
- Faster development and testing cycles

## Architecture Pattern Research

### Shared Device Accessibility Pattern
**Research Sources**: developer.apple.com (primary), wwdcnotes.com (WWDC accessibility sessions)
**Research Date**: September 21, 2025
**Key Sources by Domain**:
- **developer.apple.com**: "Build accessible apps with SwiftUI and UIKit - WWDC23", VoiceOver evaluation criteria, accessibility modifiers documentation
- **wwdcnotes.com**: "Catch up on accessibility in SwiftUI - WWDC24" summary, accessibility testing best practices
- **Community**: Swift with Majid accessibility articles, Hacking with Swift accessibility tutorials

**Approach**:
- SwiftUI automatic accessibility element creation with custom labels and hints
- AccessibilityFocusState for programmatic VoiceOver focus management during player transitions  
- privacySensitive() modifier for hiding role cards and voting information from VoiceOver
- Custom accessibility actions for complex game interactions

**Benefits**:
- Inclusive gaming experience for players with diverse abilities
- Enhanced privacy protection through accessibility-aware information hiding
- Improved usability for all players through clear focus management
- Native iOS accessibility integration without custom frameworks

**Drawbacks**:
- Additional development complexity for shared device scenarios
- Requires extensive manual testing with real VoiceOver users
- Performance considerations for complex accessibility hierarchies

**Implementation Considerations**:
- Test across full range of Dynamic Type sizes (small to accessibility extra large)
- Implement smooth focus transitions between player turns
- Validate privacy: ensure hidden information isn't announced by VoiceOver
- Consider Switch Control support for players with motor disabilities

**Decision Rationale**: Essential for constitutional accessibility-first design principle and inclusive gaming experience. Apple's 2024 accessibility enhancements provide robust foundation for shared device scenarios.

### @Observable Game State Architecture
**Research Sources**: developer.apple.com, Swift community best practices
**Research Date**: September 21, 2025
**Key Sources by Domain**:
- **developer.apple.com**: "Migrating to Observable", "Discover Observation in SwiftUI - WWDC23"
- **Community**: Swift by Sundell observation patterns, Hacking with Swift @Observable tutorials

**Approach**:
- Central @Observable GameModel containing all game state
- @ObservationIgnored for private game logic that shouldn't trigger UI updates
- Environment injection for sharing state across view hierarchy
- Computed properties for role-specific information filtering

**Benefits**:
- Optimal performance through selective property observation
- Simplified state management compared to ObservableObject
- Clean separation of public/private game information
- Automatic SwiftUI view updates on state changes

**Drawbacks**:
- Requires iOS 17+ for full @Observable support
- Learning curve for teams familiar with ObservableObject
- Need careful design to avoid exposing private information

**Implementation Considerations**:
- Design clear public/private information boundaries
- Use @ObservationIgnored for complex game logic computations
- Implement role-based computed properties for filtered data access
- Test state management thoroughly with complex game scenarios

**Decision Rationale**: Modern, performant approach that aligns with latest SwiftUI best practices and provides optimal foundation for complex game state management while maintaining privacy requirements.

## Research-Informed Recommendations

### Primary Technology Choices
- **UI Framework**: SwiftUI with NavigationStack - Native iOS support, built-in accessibility, optimal for turn-based game flow
- **State Management**: @Observable pattern with Environment injection - Modern performance, clean separation of concerns, privacy-aware
- **Testing Framework**: Swift Testing with manual accessibility validation - Latest testing practices, comprehensive game logic coverage
- **Accessibility**: Native SwiftUI modifiers with privacySensitive() - Constitutional compliance, inclusive gaming experience

### Architecture Approach
Pure SwiftUI implementation with @Observable state management, organized following Swift Guidelines directory structure. Central GameModel manages all state with computed properties for role-specific information filtering. Environment injection provides state access across view hierarchy while maintaining privacy boundaries through @ObservationIgnored annotations.

### Key Constraints Identified
- iOS 17+ requirement for full @Observable support (aligns with project's iOS 26.0+ target)
- Shared device accessibility patterns require custom implementation and extensive testing
- Complex game logic needs careful separation from UI for comprehensive testing
- Privacy information handling requires thoughtful API design to prevent accidental exposure

### Implementation Priorities
1. **Foundation**: @Observable GameModel with core game logic and state management architecture
2. **Privacy**: Role-based information filtering and privacySensitive() implementation for secure device sharing
3. **Accessibility**: VoiceOver support and focus management for inclusive group gaming experience
4. **Polish**: Advanced features like custom roles, timers, and enhanced visual feedback

---

**Next Phase**: This research provides the technical knowledge foundation for architectural planning in Tech.md.

