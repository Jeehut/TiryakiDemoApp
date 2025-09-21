# Feature Specification: WerwolfGame

**Feature Branch**: `feature/001-werwolf-game`
**Created**: September 21, 2025
**Status**: Draft
**Input**:
"""
We want to develop the game "Werwolf" (thats how its called in Germany) asn an iOS app. But we want to play it with 3 people or more, it should flexibily adjust the characters, maybe you can even choose them. The app will be used by all players, they players are connected and everyone knows who they are. One phone is put in the middle and everyone uses that somehow. But how exactly it works would need to be thought about, so it works practically, this is part of the questions to answer before eeveloping the app.
"""

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a group of friends gathering for social gaming, I want to play Werwolf using a single shared iOS device so that we can enjoy this social deduction game together without needing physical cards or a separate game master.

**Platform Context**:
- **Multi-platform**: Optimized for iPhone/iPad shared device usage with clear, large UI elements visible to all players seated around the device. iOS-first design with potential macOS support for larger groups.
- **User Experience**: Turn-based interface where players pass the device, with clear visual and audio cues for role reveals, voting phases, and game state transitions. Accessibility support for diverse player abilities.
- **Data Handling**: Local game sessions with no persistent data storage required. Player names and roles stored temporarily during active games only, with privacy-first design ensuring no tracking of individual players.

### Acceptance Scenarios

1. **Given** a group of 3-12 players wants to start a new Werwolf game, **When** they launch the app and enter player names, **Then** the system automatically assigns balanced roles based on player count and displays the game setup confirmation.
   - **Happy Path**: 6 players enter names, system assigns 1 Seer, 1 Doctor, 2 Werewolves, 2 Villagers, all players confirm their understanding
   - **Error Path**: Player tries to start with only 2 players, system displays minimum player requirement and prevents game start
   - **Edge Cases**: 12 players join (maximum), system correctly scales roles; duplicate names entered, system prompts for unique names

2. **Given** the game is in night phase, **When** a player with a night role (Werewolf, Seer, Doctor) receives the device, **Then** they see only their role-specific options and can make their choice privately before passing the device.
   - **Happy Path**: Werewolf selects victim, Seer selects investigation target, Doctor selects protection target, each action is recorded privately
   - **Error Path**: Player accidentally sees screen during wrong phase, system provides clear instructions to pass device to correct player
   - **Edge Cases**: Player takes too long (optional timer), system provides gentle prompts; device locked/interrupted, game state is preserved

3. **Given** the game transitions to day phase, **When** all players discuss and vote to eliminate someone, **Then** the system manages voting privately and reveals results to all players simultaneously.
   - **Happy Path**: Each player secretly votes via the device, system tallies votes and announces elimination with dramatic reveal
   - **Error Path**: Voting round ends in tie, system manages tiebreaker procedure according to game rules
   - **Edge Cases**: Player changes vote before submission deadline; eliminated player was the last werewolf (villagers win) or last villager (werewolves win)

4. **Given** players want to customize their game experience, **When** they access game setup options, **Then** they can select which roles to include and adjust game rules within balanced parameters.
   - **Happy Path**: Players enable/disable optional roles (Hunter, Cupid), adjust timer settings, system validates balance
   - **Error Path**: Player creates unwinnable scenario (too many werewolves), system provides balance warnings
   - **Edge Cases**: Advanced players want custom roles, system provides framework for house rules

### Edge Cases
- **Platform variations**: iPhone vs iPad screen size optimization - larger devices show more detailed role information and accommodate larger player groups more comfortably
- **Multi-device usage**: Single device design eliminates sync issues but requires clear handoff protocols between players during different game phases
- **App lifecycle**: Background/foreground transitions during active game preserve current state; incoming calls or notifications don't disrupt game flow with appropriate state management
- **Network conditions**: Fully offline gameplay - no network dependency ensures consistent experience regardless of connectivity
- **User scenarios**: Mixed age groups (children and adults) require adjustable complexity; players with accessibility needs benefit from VoiceOver support and large text options; competitive vs casual play modes affect timer pressure and rule strictness

🚨 [NEEDS CLARIFICATION: Should the app support multiple simultaneous games on different devices, or is single-device shared experience the exclusive design pattern?]

🚨 [NEEDS CLARIFICATION: What is the preferred approach for role assignment - completely random, host-controlled selection, or player preference input with balancing?]

🚨 [NEEDS CLARIFICATION: Should game history or statistics be tracked between sessions, or is each game completely ephemeral?]

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support game creation for 3-12 players with automatic role assignment that ensures game balance (minimum 1 werewolf for 3-6 players, 2 werewolves for 7-12 players, appropriate special roles based on player count)

- **FR-002**: System MUST provide private role revelation where each player can view their role and instructions without other players seeing, with clear visual and audio cues for device handoff

- **FR-003**: System MUST manage day/night game phases with distinct UI states - night phase for role actions (werewolf elimination, seer investigation, doctor protection) and day phase for group discussion and voting

- **FR-004**: System MUST implement secret voting mechanism where each player can vote privately to eliminate a suspect, with vote tallying and tie-breaking procedures according to standard Werwolf rules

- **FR-005**: System MUST detect and announce win conditions (all werewolves eliminated = villagers win, werewolves equal or outnumber villagers = werewolves win) with appropriate celebratory feedback

- **FR-006**: System MUST provide role customization allowing players to enable/disable optional roles (Hunter, Cupid, Mayor) while maintaining game balance validation

- **FR-007**: System MUST preserve game state during app lifecycle events (backgrounding, interruptions) to ensure uninterrupted gameplay experience

- **FR-008**: System MUST support accessibility features including VoiceOver compatibility, Dynamic Type scaling, and high contrast modes for inclusive gameplay

*Each requirement is testable through user scenarios, focused on player experience value, and avoids technical implementation specifics*

## Scope Boundaries *(mandatory)*

- **IN SCOPE**: 
  - Single-device shared gameplay for 3-12 players
  - Core Werwolf roles (Villager, Werewolf, Seer, Doctor) with automatic balancing
  - Optional advanced roles (Hunter, Cupid, Mayor) with toggle controls
  - Private role revelation and action phases
  - Secret voting and elimination mechanics
  - Win condition detection and celebration
  - Accessibility support (VoiceOver, Dynamic Type, high contrast)
  - Game state preservation during interruptions
  - Basic game customization (roles, timers)

- **OUT OF SCOPE**: 
  - Network multiplayer or remote device connectivity
  - Player accounts, profiles, or persistent data storage
  - Game statistics, leaderboards, or historical tracking
  - Advanced AI opponents or computer players
  - Voice chat or communication features
  - Integration with social media or external services
  - Complex custom role creation tools
  - Multi-language localization (English-first release)
  - Apple Watch or other companion device support

