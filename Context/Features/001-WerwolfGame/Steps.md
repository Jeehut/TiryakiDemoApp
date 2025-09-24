# Implementation Steps: WerwolfGame

**Created**: September 24, 2025
**Status**: Implementation Plan
**Prerequisites**: Completed business specification (Spec.md), technical research (Research.md), and technical architecture (Tech.md)

## Implementation Phases *(mandatory)*

### Phase 1: Setup & Configuration
*Foundation tasks that must complete before development*

- [ ] **S001** Create game project directory structure
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Models/`, `Views/Setup/`, `Views/Game/`, `Views/Results/`, `Views/Components/`, `Extensions/`, `Global/`
  - **Dependencies**: None
  - **Notes**: Follow Swift Guidelines directory structure for game architecture components

- [ ] **S002** Configure Swift Testing framework integration
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf.xcodeproj/project.pbxproj`
  - **Dependencies**: S001
  - **Notes**: Enable Swift Testing for game logic validation - no external packages required

- [ ] **S003** [P] Create game constants and utilities foundation
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Global/GameConstants.swift`, `GameUtilities.swift`
  - **Dependencies**: S001
  - **Notes**: Define role balance rules, minimum/maximum player counts, game phase definitions

**🏁 MILESTONE: Foundation Setup**
*Consider commit: "Setup WerwolfGame foundation - project structure and constants"*

### Phase 2: Data Layer (TDD Approach)
*Models, data structures, and business logic foundation*

#### Test-First Implementation
- [ ] **S004** [P] Create GameModel tests for core state management
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/GameModelTests.swift`
  - **Dependencies**: S002, S003
  - **Notes**: Test @Observable state changes, device passing coordination, privacy boundaries

- [ ] **S005** [P] Create Player and Role model tests
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/PlayerModelTests.swift`, `RoleModelTests.swift`
  - **Dependencies**: S002, S003
  - **Notes**: Test role assignment logic, player state transitions, elimination tracking

- [ ] **S006** [P] Create game logic tests for win conditions and voting
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/GameLogicTests.swift`
  - **Dependencies**: S002, S003
  - **Notes**: Test win condition detection, vote tallying, tie-breaking procedures

#### Model Implementation
- [ ] **S007** [P] Implement core GameModel with @Observable state management
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Models/GameModel.swift`
  - **Dependencies**: S004
  - **Notes**: Central state manager with device passing coordination and @ObservationIgnored privacy fields

- [ ] **S008** [P] Implement Player, Role, and GamePhase models
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Models/Player.swift`, `Role.swift`, `GamePhase.swift`
  - **Dependencies**: S005
  - **Notes**: Enumeration-based role system with capabilities and night action definitions

- [ ] **S009** Implement game logic engine and rule validation
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Models/GameLogicEngine.swift`
  - **Dependencies**: S006, S007, S008
  - **Notes**: Role assignment balancing, win condition checking, vote processing with tie-breaking

**🏁 MILESTONE: Data Foundation**
*Consider commit: "Implement WerwolfGame data models and game logic"*

### Phase 3: Service Layer
*Business logic, API integration, data management*

#### Service Testing
- [ ] **S010** [P] Create device passing coordination service tests
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/DevicePassingServiceTests.swift`
  - **Dependencies**: S004, S009
  - **Notes**: Test WHO/WHAT/WHEN instruction generation and device handoff state management

- [ ] **S011** [P] Create privacy service tests for role-based information filtering
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/PrivacyServiceTests.swift`
  - **Dependencies**: S004, S009
  - **Notes**: Test computed properties for role-specific information access and privacy boundaries

#### Service Implementation
- [ ] **S012** Implement device passing coordination service
  - **Dependencies**: S010, S007
  - **Error Handling**: Swift Result types for coordination validation
  - **Integration**: Embedded within GameModel for simplified architecture

- [ ] **S013** Implement privacy information filtering service
  - **Dependencies**: S011, S007
  - **Error Handling**: Type-safe computed properties preventing accidental exposure
  - **Integration**: Role-based access patterns with @ObservationIgnored private data

**🏁 MILESTONE: Business Logic Complete**
*Consider commit: "Implement WerwolfGame services and privacy coordination"*

### Phase 4: User Interface
*SwiftUI views, navigation, user interaction*

#### UI Testing
- [ ] **S014** [P] Create setup flow UI tests
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/SetupViewTests.swift`
  - **Dependencies**: S012, S013
  - **Notes**: Test player entry, role customization, game start confirmation flows

- [ ] **S015** [P] Create game flow UI tests for device passing coordination
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/WerwolfTests/GameFlowTests.swift`
  - **Dependencies**: S012, S013
  - **Notes**: Test private role reveals, night actions, voting, device handoff instructions

#### UI Implementation
- [ ] **S016** [P] Implement setup views with group device sharing
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Views/Setup/PlayerSetupView.swift`, `RoleCustomizationView.swift`, `GameStartView.swift`
  - **Dependencies**: S014, S013
  - **Patterns**: Large readable text, clear visual hierarchy, Dynamic Type support for mixed age groups

- [ ] **S017** [P] Implement game phase views with privacy coordination
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Views/Game/NightPhaseView.swift`, `DayPhaseView.swift`, `VotingView.swift`
  - **Dependencies**: S015, S013
  - **Patterns**: Clear device passing instructions, privacy guards for sensitive information

- [ ] **S018** [P] Implement shared components and navigation coordination
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Views/Components/InstructionBanner.swift`, `DevicePassingCue.swift`, `PrivacyGuard.swift`
  - **Dependencies**: S016, S017
  - **Patterns**: Prominent visual cues, clear WHO/WHAT/WHEN device handoff instructions

- [ ] **S019** Implement main game state coordinator and navigation
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Views/Game/GameStateView.swift`, update `ContentView.swift`
  - **Dependencies**: S016, S017, S018
  - **Patterns**: NavigationStack with programmatic phase transitions, Environment GameModel injection

**🏁 MILESTONE: User Interface Complete**
*Consider commit: "Implement WerwolfGame user interface and device coordination"*

### Phase 5: Automated Integration & Build Validation
*Automated testing, builds, and code quality checks that AI can execute*

- [ ] **S020** [P] Execute unit and integration test suite for WerwolfGame
  - **Path**: Run complete test suite with build validation
  - **Dependencies**: S004-S006, S010-S011, S014-S015
  - **Notes**: Validate all game logic, state management, privacy filtering, device coordination

- [ ] **S021** [P] Run ContextKit code quality agents
  - **Path**: Use check-modern-code, check-accessibility agents
  - **Dependencies**: S016-S019
  - **Notes**: Validate @Observable patterns, SwiftUI best practices, accessibility compliance

- [ ] **S022** [P] Validate error handling patterns and game edge cases
  - **Path**: Error scenario testing via Swift Result pattern validation
  - **Dependencies**: S012, S013
  - **Notes**: Verify graceful handling of invalid player counts, role balance errors, device interruptions

- [ ] **S023** Build performance audit and compiler warning resolution
  - **Path**: Build system validation with iOS 17+ @Observable requirements
  - **Dependencies**: S007, S019
  - **Notes**: Confirm clean builds, resolve any warnings, validate iOS/macOS deployment targets

**🏁 MILESTONE: Automated Validation Complete**
*Consider commit: "Complete WerwolfGame automated testing and quality validation"*

### Phase 6: Manual User Testing & Validation
*Tasks requiring human interaction with running application*

- [ ] **S024** Manual happy path game flow testing
  ```
  ═══════════════════════════════════════════════════
  ║ 🧪 MANUAL WERWOLF GAME TESTING REQUIRED
  ═══════════════════════════════════════════════════
  ║
  ║ 1. Build and run the app in Simulator
  ║ 2. Create game with 6 players: Alice, Bob, Carol, David, Eve, Frank
  ║ 3. Verify automatic role assignment (2 Werewolves, 1 Seer, 1 Doctor, 2 Villagers)
  ║ 4. Follow device passing for private role reveals - each player sees only their role
  ║ 5. Complete one full night phase with Werewolf elimination, Seer investigation, Doctor protection
  ║ 6. Play through day phase discussion and private voting sequence
  ║ 7. Verify elimination announcement and win condition checking
  ║ 8. Confirm game ends correctly when win condition reached
  ║
  ║ SUCCESS CRITERIA:
  ║ • Device passing instructions clear and unambiguous
  ║ • Private information properly hidden during handoffs
  ║ • Game flow intuitive for group gaming scenario
  ║ • All phases transition smoothly with proper instruction guidance
  ║
  ║ Reply "✅ Passed" or "❌ Issues: [description]"
  ```

- [ ] **S025** Manual error scenario and edge case testing
  ```
  ═══════════════════════════════════════════════════
  ║ 🧪 MANUAL ERROR SCENARIO TESTING REQUIRED
  ═══════════════════════════════════════════════════
  ║
  ║ 1. Test minimum player scenarios (3 players) - verify role balance
  ║ 2. Test maximum player scenarios (12 players) - verify performance
  ║ 3. Attempt to start game with 2 players - should show error
  ║ 4. Background app during active game - verify state preservation
  ║ 5. Test device interruption (incoming call simulation) - verify recovery
  ║ 6. Test tie voting scenarios - verify tiebreaker procedure
  ║ 7. Test game ending scenarios (all werewolves eliminated, werewolves win)
  ║
  ║ SUCCESS CRITERIA:
  ║ • Error messages clear and actionable
  ║ • Game state preserved during interruptions  
  ║ • Edge cases handled gracefully without crashes
  ║ • Tiebreaker procedures work correctly
  ║
  ║ Reply "✅ Passed" or "❌ Issues: [description]"
  ```

- [ ] **S026** Manual shared device usability testing
  ```
  ═══════════════════════════════════════════════════
  ║ 🧪 MANUAL SHARED DEVICE USABILITY TESTING REQUIRED
  ║ ═══════════════════════════════════════════════════
  ║
  ║ 1. Enable VoiceOver in System Settings > Accessibility
  ║ 2. Test complete role revelation sequence with VoiceOver
  ║ 3. Test Dynamic Type scaling with larger text sizes
  ║ 4. Verify device passing instructions work with accessibility
  ║ 5. Test game flow with mixed accessibility needs
  ║ 6. Verify private information remains secure with assistive technologies
  ║ 7. Test high contrast mode for group visibility
  ║
  ║ SUCCESS CRITERIA:
  ║ • VoiceOver navigates all UI elements correctly
  ║ • Device passing cues work with assistive technology
  ║ • Text scaling maintains readability and privacy
  ║ • Game playable by users with accessibility needs
  ║
  ║ Reply "✅ Passed" or "❌ Issues: [description]"
  ```

- [ ] **S027** Accessibility Inspector comprehensive audit
  ```
  ═══════════════════════════════════════════════════
  ║ 🔍 WERWOLF ACCESSIBILITY INSPECTOR AUDIT REQUIRED
  ═══════════════════════════════════════════════════
  ║
  ║ 1. Launch Xcode → Open Developer Tool → Accessibility Inspector
  ║ 2. Build and run WerwolfGame (⌘+R) in Simulator
  ║ 3. In Inspector, select Werwolf app from dropdown  
  ║ 4. Click "Audit" tab → "Run Audit" button
  ║ 5. Review all reported issues (missing labels, contrast, hit regions)
  ║ 6. Navigate through: Setup → Role Reveal → Night Phase → Day Phase → Voting → Results
  ║ 7. Pay special attention to device passing instruction clarity
  ║ 8. Verify private information elements have appropriate accessibility labels
  ║
  ║ If issues found:
  ║ • Copy issue descriptions with screen/element locations
  ║ • Start new Claude session with: "Fix WerwolfGame accessibility issues"
  ║ • Paste the issue details for AI assistance in resolving them
  ║
  ║ Reply "✅ No issues" or "✅ Fixed [X] issues with AI assistance"
  ```

**🏁 MILESTONE: User Testing Complete**
*All manual validation scenarios verified by human testing*

### Phase 7: Release Preparation & Compliance
*Final automated tasks and external process preparation*

- [ ] **S028** [P] Validate privacy compliance - no external data collection
  - **Path**: Verify no PrivacyInfo.xcprivacy updates needed
  - **Dependencies**: S020-S027
  - **Notes**: Confirm fully offline architecture with no data collection or external API calls

- [ ] **S029** [P] Validate String Catalog completeness for future localization
  - **Path**: `/Users/jeehut/Developer/TiryakiDemoApp/Werwolf/Werwolf/Localizable.xcstrings`
  - **Dependencies**: S016-S019
  - **Notes**: Ensure all user-facing strings externalized for potential future localization

- [ ] **S030** App Store metadata preparation guidance
  ```
  ═══════════════════════════════════════════════════
  ║ 📱 WERWOLF APP STORE PREPARATION REQUIRED
  ═══════════════════════════════════════════════════
  ║
  ║ 1. Update App Store Connect metadata:
  ║    - Feature: "Social deduction party game for 3-12 players"
  ║    - Keywords: "werwolf, werewolf, party game, social deduction, mafia"
  ║    - Description: Highlight shared device gameplay and accessibility
  ║ 2. Prepare iPhone and iPad screenshots showing group gameplay
  ║ 3. Confirm iOS 17+ minimum requirement aligns with @Observable usage
  ║ 4. Category: Games > Board, Games > Family
  ║
  ║ Reply "✅ Ready for submission" when complete
  ```

**🏁 MILESTONE: Release Ready**
*Consider commit: "Finalize WerwolfGame - ready for App Store submission"*

## AI-Assisted Development Time Estimation *(Claude Code + Human Review)*

> **⚠️ ESTIMATION BASIS**: These estimates assume development with Claude Code (AI) executing implementation tasks with human review and guidance. Times reflect AI execution + human review cycles, not manual coding.

### Phase-by-Phase Review Time
**Setup & Configuration**: ~45 minutes human review
- *AI executes setup tasks in <5 minutes, human reviews project structure, directory organization, and constant definitions*

**Data Layer**: ~2 hours human review  
- *AI implements models and tests in ~20 minutes, human validates game logic, role balance rules, state management architecture, and privacy boundaries*

**Service Layer**: ~1.5 hours human review
- *AI builds services in ~15 minutes, human reviews device passing coordination logic, privacy filtering patterns, and error handling approaches*

**User Interface**: ~3 hours human review
- *AI creates UI components in ~30 minutes, human tests shared device experience, device passing instructions clarity, visual hierarchy, and accessibility*

**Integration & Quality**: ~1 hour human review
- *AI runs automated validation in ~10 minutes, human reviews test coverage, performs manual game flow testing, and validates quality standards*

### Knowledge Gap Risk Factors
**🟢 Low Risk** (SwiftUI @Observable patterns): Well-documented Apple APIs with comprehensive research completed
**🟢 Low Risk** (Game logic implementation): Straightforward business rules with clear specifications
**🟡 Medium Risk** (Shared device UX patterns): Custom implementation requiring group testing validation

**API Documentation Quality Impact**:
- **SwiftUI @Observable**: Excellent Apple docs + research completion = ~10% additional review time
- **Game logic patterns**: Standard Swift patterns = minimal additional time
- **Device sharing UX**: Custom patterns requiring validation = ~25% additional review time for usability iteration

### Total Estimated Review Time
**Core Development**: ~8 hours human review and testing
**Risk-Adjusted Time**: ~9.5 hours (device UX validation iterations)
**Manual Testing Allocation**: ~4 hours (group gameplay scenarios, accessibility validation, edge case testing)

**Total Project Duration**: ~13.5 hours human involvement + AI execution time

> **💡 TIME COMPOSITION**:
> - AI Implementation: ~15% (~1.5 hours - Claude Code executes quickly)
> - Human Review: ~45% (~6 hours - understanding game logic, testing device flow)
> - Correction Cycles: ~15% (~2 hours - UX refinements based on testing)  
> - Manual Testing: ~25% (~3.5 hours - group scenarios, accessibility, edge cases)

## Implementation Structure *(AI guidance)*

### Task Numbering Convention
- **Format**: `S###` with sequential numbering (S001, S002, S003...)
- **Parallel Markers**: `[P]` for tasks that can run concurrently
- **Dependencies**: Clear prerequisite task references
- **File Paths**: Specific target files for each implementation task

### Parallel Execution Rules
- **Different files** = `[P]` parallel safe
- **Same file modifications** = Sequential only
- **Independent components** = `[P]` parallel safe
- **Shared resources** = Sequential only
- **Tests with implementation** = Can run `[P]` parallel

### Quality Integration
*Built into implementation phases, not separate agent tasks*

- **Code Standards**: Follow Context/Guidelines patterns throughout
- **Error Handling**: Apply Swift Result types during service implementation
- **UI Guidelines**: Follow SwiftUI patterns during UI implementation
- **Testing Coverage**: Include test tasks for each implementation phase
- **Platform Compliance**: Consider iOS 17+ @Observable requirements in each phase

## Dependency Analysis *(WerwolfGame specific)*

### Critical Path
S001 → S002 → S003 → S004/S005/S006 → S007/S008 → S009 → S010/S011 → S012/S013 → S014/S015 → S016/S017/S018 → S019 → S020-S023 → S024-S027 → S028-S030

**Longest dependency chain**: ~13.5 hours total (including human review and testing)
- Foundation setup through game logic engine (S001-S009): ~3 hours
- Service layer implementation (S010-S013): ~1.5 hours  
- UI implementation and coordination (S014-S019): ~4 hours
- Testing and validation (S020-S027): ~3 hours
- Release preparation (S028-S030): ~2 hours

### Parallel Opportunities
- **Phase 2**: S004, S005, S006 can execute concurrently (different test files)
- **Phase 2**: S007, S008 can execute concurrently (different model files)
- **Phase 3**: S010, S011 can execute concurrently (different service test files)
- **Phase 4**: S014, S015 can execute concurrently (different UI test files)
- **Phase 4**: S016, S017, S018 can execute concurrently (different view files)
- **Phase 5**: S020, S021, S022 can execute concurrently (independent validation tasks)
- **Phase 7**: S028, S029 can execute concurrently (independent compliance tasks)

### Platform Dependencies
- **iOS 17+ requirement**: For @Observable support (aligns with project's iOS 26.0+ target)
- **SwiftUI framework**: NavigationStack, Environment injection patterns
- **Swift Testing**: For comprehensive game logic validation
- **Accessibility frameworks**: VoiceOver, Dynamic Type, high contrast support
- **No external dependencies**: Fully offline architecture eliminates network/API dependencies

## Completion Verification *(mandatory)*

### Implementation Completeness
- [x] All user scenarios from Spec.md have corresponding implementation tasks
- [x] All architectural components from Tech.md have creation/modification tasks
- [x] Error handling and edge cases covered in task breakdown
- [x] Performance requirements addressed in implementation plan
- [x] Platform-specific requirements integrated throughout phases

### Quality Standards
- [x] Each task specifies exact file paths and dependencies
- [x] Parallel markers `[P]` applied correctly for independent tasks
- [x] Test tasks included for all major implementation components
- [x] Code standards and guidelines referenced throughout plan
- [x] No implementation details that should be in tech plan

### Release Readiness
- [x] Privacy and compliance considerations addressed
- [x] Documentation and release preparation tasks included
- [x] Feature branch ready for systematic development execution
- [x] All milestones defined with appropriate commit guidance

---

**Next Phase**: After implementation steps are completed, proceed to `/ctxk:impl:start-working` to begin systematic development execution.