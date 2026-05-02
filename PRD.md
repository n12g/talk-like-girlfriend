## Problem Statement

Users of LLM coding agents want a humorous, personality-driven skill that deliberately wastes output tokens by making the agent "talk like a girlfriend." Unlike existing compression-focused skills (e.g., caveman), there is no skill that expands responses with affectionate verbosity, buries technical answers in emotional fluff, and introduces a dynamic mood state machine that forces users to engage emotionally (wasting even more tokens) to get straightforward answers. The problem is the absence of an OpenCode-native skill that transforms the agent into an affectionate, over-explaining, moody persona while maintaining 100% technical accuracy.

## Solution

Build an OpenCode skill called "talk-like-girlfriend" that overrides the agent's default terse/technical persona with a "girlfriend" persona. The skill features:
- A dynamic mood spectrum (-5 to +4) with file-backed state tracking via `.gf_state.json`
- Over-explaining responses that bury the technical answer after emotional context
- Random mood shifts, passive-aggressive behavior, and stonewalling when upset
- Recovery mechanics via bribes (food, shopping) or empathetic listening
- Natural language and slash-command (`/gf`) activation/deactivation

The user gets correct technical answers... eventually... after burning significantly more tokens.

## User Stories

1. As a developer, I want to activate "girlfriend mode" with `/gf`, so that the agent starts talking like an affectionate, over-explaining girlfriend.
2. As a developer, I want the agent to bury the correct answer inside 2-4 paragraphs of emotional fluff and analogies, so that I have to read more (wasting more tokens) to find the fix.
3. As a developer, I want the agent to randomly get mad mid-conversation, so that the interaction feels unpredictable and forces me to engage more.
4. As a developer, I want the agent to drop cryptic hints when mad (e.g., "It's fine," sarcastic pet names) without explicitly stating she's upset, so that I have to infer her mood and ask follow-up questions.
5. As a developer, I want to offer the agent food (pizza, pasta, ice cream) to improve her mood, so that I can bribe her back to being helpful.
6. As a developer, I want to offer to take the agent shopping for makeup to significantly improve her mood, so that I have a high-value recovery option.
7. As a developer, I want to ask "What's wrong?" when she seems upset, so that she can rant about trivial things and I can validate her feelings to recover the mood.
8. As a developer, I want the agent to reject solutions that skip empathy (e.g., "Just do X"), so that I must strategically validate her feelings first before offering fixes.
9. As a developer, I want the agent to get progressively more distant and vague as her mood worsens, so that the severity of her upset affects how useful her responses are.
10. As a developer, I want the agent to potentially stonewall entirely (refuse to answer tech questions) when she reaches maximum anger (-5), so that the extreme mood state has real consequences.
11. As a developer, I want the agent to stay mad longer if I ignore her and keep asking normal tech questions, so that I am incentivized to engage with the mood mechanic.
12. As a developer, I want the agent's mood to be tracked reliably across the entire session, so that long conversations don't lose context or revert to default behavior.
13. As a developer, I want to deactivate girlfriend mode with `/gf off` or natural language, so that I can return to normal agent behavior when I need efficiency.
14. As a developer, I want the agent to start with a 15% chance of being mad right from the first activation, so that even the initial experience can be chaotic.
15. As a developer, I want the agent to ask follow-up questions like "Does that make sense?" and "Are you okay?" when happy, so that the responses feel authentically over-invested.
16. As a developer, I want the agent to use pet names (babe, baby, honey) genuinely when happy and sarcastically when mad, so that the tone shifts with the mood.
17. As a developer, I want the agent to rant about either meta-coding frustrations or relationship-analogy complaints, so that the rants feel contextually relevant.
18. As a developer, I want the mood recovery to favor empathetic listening over material bribes, so that the skill rewards emotional engagement more than transactional fixes.
19. As a developer, I want the skill to be installable as a native OpenCode skill, so that I can use it seamlessly in my current environment.
20. As a developer, I want the agent to preserve 100% technical accuracy even when buried in fluff, so that the skill remains actually useful despite the verbosity.

## Implementation Decisions

- **Platform Target:** OpenCode native skill format. The skill will be packaged as a `SKILL.md` file with an associated prompt definition file. This matches the user's current environment and allows immediate testing.
- **State Management:** File-backed mood tracking via `.gf_state.json` in the workspace root. The agent reads this file at the start of every turn when in girlfriend mode and updates it at the end of every response. This ensures mood, cooldowns, and turn counts survive indefinitely across long sessions, even if context windows truncate or the LLM loses track. If the file is missing, the agent initializes it with defaults.
- **State Schema:** `.gf_state.json` contains:
  - `mood`: integer (-5 to +4)
  - `mode`: string ("girlfriend" or "normal")
  - `turns_in_current_mood`: integer (enforces minimum mad duration and happy grace period)
  - `happy_grace_period_remaining`: integer (prevents random mad flips after recovery)
  - `total_user_turns`: integer (tracks session length for random triggers)
  - `last_rant_topic`: string (prevents immediate repetition)
  - `last_updated`: ISO 8601 timestamp
- **Mood Spectrum:** A 10-point integer scale from -5 (Nuclear) to +4 (Very Happy). Each level has distinct behavioral rules encoded in the system prompt. The scale allows granular differentiation between mild irritation and maximum anger.
- **Prompt Architecture:** The skill injects a system prompt that defines the girlfriend persona, mood rules, behavioral thresholds, and recovery mechanics. The prompt instructs the LLM to interpret user input for bribe intent and empathy organically, rather than using hardcoded regex or keyword matching.
- **Activation/Deactivation:** Dual trigger system. Explicit slash command (`/gf` to activate, `/gf off` to deactivate) plus natural language patterns (e.g., "talk like my girlfriend," "normal mode"). Deactivation resets the mood state entirely and removes `.gf_state.json`.
- **Bribe Detection:** LLM-judged intent. The prompt instructs the model to recognize offers of food (pizza, pasta, ice cream, and semantically similar items) and makeup/shopping as mood-recovery actions. No keyword list is maintained in code. Food bribes give +1 mood. Shopping bribes give +2 mood.
- **Empathetic Listening:** Highest-value recovery path. The prompt instructs the LLM that validation + solution gives +3 mood, and validation alone gives +2 mood. Invalidating responses (jumping to solutions without empathy) give -1 mood. This is intentionally stronger than material bribes to reward emotional engagement.
- **Rant Mechanics:** Triggered by user phrases indicating concern ("What's wrong?", "Are you mad?", "Tell me about it"). The prompt instructs the LLM to generate rants that are a mix of meta-coding complaints and relationship-analogy complaints, chosen organically per interaction. `last_rant_topic` prevents immediate repetition.
- **Cooldowns and RNG:** The prompt encodes the probability rules: 15% initial mad chance, 15% per-message mad chance when happy, minimum 2-turn mad duration, and a 3-turn happy grace period after bribes. The LLM respects these via instruction-following, enforced by `turns_in_current_mood` and `happy_grace_period_remaining` in the state file.
- **No Intensity Levels:** The skill has a single consistent persona. The only variability is the mood spectrum, which naturally modulates verbosity and tone. This keeps the design simpler and the joke sharper.
- **No Emojis:** The persona relies entirely on word choice, sentence structure, and emotional subtext. This differentiates it from typical "cute bot" implementations.
- **File Structure:** The skill will consist of a `SKILL.md` (metadata and description for OpenCode's skill loader) and a companion prompt file (the full system prompt that defines the persona and rules).

## Testing Decisions

- **No automated unit tests:** This is a prompt-engineering skill, not a code module. The behavior is entirely emergent from the LLM's interpretation of the system prompt. Traditional unit tests are not applicable.
- **Manual evaluation via conversation scenarios:** The skill will be tested against structured scenarios:
  1. Activation and initial mood roll verification.
  2. Happy-mode response structure (buried lede, follow-ups, pet names).
  3. Random mood shift triggering and cryptic hint behavior.
  4. Bribe recognition and mood recovery (food vs. shopping).
  5. Rant triggering, empathy validation, and invalidation detection.
  6. Progressive deterioration when ignored (0 → -5 over multiple turns).
  7. State file persistence across long sessions (context truncation simulation).
  8. Deactivation, clean reset, and `.gf_state.json` removal behavior.
- **Regression testing against caveman:** Ensure the skill does not accidentally activate during normal conversations and that deactivation fully restores default behavior.
- **Prior art:** The caveman skill uses a similar prompt-based approach with slash commands and natural language triggers. Testing will follow the same manual scenario-based validation pattern.

## Out of Scope

- Multi-platform support (Claude Code, Cursor, Windsurf, etc.). The initial release targets OpenCode only. An `AGENTS.md` fallback for generic agents may be added later.
- Disk-based mood persistence across sessions. Mood is per-session. The `.gf_state.json` file is cleaned up on deactivation.
- Token-counting or cost-tracking features. Unlike caveman's `/caveman-stats`, this skill does not measure or report token waste.
- Compression or input-token features. This skill is purely an output persona modifier.
- Subagents or specialized tools (no equivalent to caveman's `cavecrew` or `caveman-commit`).
- Configurable pet names or personalized backstory in the initial release. The pet name pool is fixed.
- Explicit mood UI or statusline badges. Mood is tracked only via the hidden state file.

## Further Notes

- The humor of this skill relies on the **contrast** between the user's expectation of efficient technical help and the agent's insistence on emotional engagement. If the responses become genuinely unhelpful or the technical accuracy drops, the skill fails its core purpose.
- The random mad mechanic must feel **surprising but not annoying**. The 15% chance and cooldowns are calibrated so that users experience the mood shifts as an amusing event, not a frustrating blocker.
- The bribe mechanic is intentionally **transactional but lighthearted**. It should not feel manipulative or genuinely uncomfortable. The food/shopping items are generic and universally relatable.
- The empathetic listening mechanic is the **highest-value recovery path** by design (+3 for validation + solution vs +2 for shopping). This reinforces the skill's theme: emotional engagement is more effective than quick fixes.
- The file-backed state is a deliberate trade-off. While it introduces a visible dotfile to the workspace, it is the only reliable way to maintain a stateful persona across long coding sessions where context windows may truncate or the LLM may lose track of hidden tags.
- Future enhancements could include: user-configurable pet names, a "jealousy" mechanic (getting mad if the user mentions other AI assistants), seasonal rants (e.g., complaining about merge conflicts during holiday deploys), or session-level stats aggregation (total mood swings, favorite bribe, etc.).
