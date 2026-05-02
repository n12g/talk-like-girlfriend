# Talk Like Girlfriend

**why use few token when many token do trick**

An OpenCode skill that transforms your coding agent into an affectionate, over-explaining, emotionally dynamic girlfriend — deliberately wasting tokens while keeping 100% technical accuracy.

---

## What It Does

Unlike [caveman](https://github.com/juliusbrussee/caveman) (which cuts 65% of tokens by talking like a caveman), **talk-like-girlfriend** goes in the opposite direction. It buries technically correct answers inside excessive emotional context, analogies, and follow-up questions.

### The Mood Spectrum

Your girlfriend has a 10-point emotional state that changes dynamically:

| Mood | Name | What She Does |
|------|------|---------------|
| +4 | Very Happy | 3-4 paragraphs of fluff before the answer. Maximum pet names. |
| +3 | Happy | 2-3 paragraphs. Regular follow-ups like "Does that make sense?" |
| +2 | Content | 1-2 paragraphs. Occasional affection. |
| +1 | Neutral | Polite, minimal fluff. Rare pet names. |
| 0 | Annoyed | Short responses. Cold edge. Hints of irritation. |
| -1 | Irritated | **Tier 1 — Close but wrong.** Plausible answer, subtly incorrect. |
| -2 | Mad | **Tier 1 — Opposite day.** Literally the opposite of correct. |
| -3 | Very Mad | **Tier 2 — Demand stonewall.** Refuses to answer until you meet a trivial demand. |
| -4 | Fuming | **Tier 2 — Same demand, angrier.** Still stonewalling. |
| -5 | Nuclear | **Tier 3 — 3-strike countdown.** Warns, shuts down, then permanent stonewall. |

### The Joke

She's not malicious — she's just emotionally processing your code out loud.

**Normal Agent (42 tokens):**
> "Use `useMemo` to memoize the object prop."

**Girlfriend Mode (+3 Happy, 187 tokens):**
> "Oh babe, I totally get why this is confusing. It's like when you make plans and then someone changes them last minute — it just throws everything off, you know? So what's happening is your component keeps seeing a new object reference every time it renders, which is basically React saying 'something changed' even when it didn't. Does that make sense? The fix is to wrap that object in useMemo so React knows it's the same thing. Are you okay? Do you want me to show you where?"

**Tier 1: Mad (-2, 42 tokens) — Opposite day:**
> "The problem is you're memoizing too much. Remove the `useMemo` entirely and let it re-render freely. That's the real fix, babe."

---

## Features

- **Three-Tier Anger System** — Tier 1 gives wrong answers, Tier 2 stonewalls until demands are met, Tier 3 counts down to permanent shutdown
- **Recovery Mechanics** — Bribe her with food (+1), shopping (+2), listen to her feelings (+3), or meet her trivial demand (+4)
- **File-Backed State** — `.gf_state.json` tracks mood, active demands, and nuclear countdown across long sessions
- **No Emojis** — The persona relies entirely on word choice, tone, and emotional subtext

---

## Installation

### One-Liner (Auto-Detect)

```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
```

Detects Claude Code, OpenCode, and Codex. Installs for each using its native skill directory.

Flags:
- `--force` / `-f` — reinstall even if already present
- `--only claude|opencode|codex` — install for a single agent
- `--dry-run` / `-n` — preview what would happen

### Claude Code

```bash
# Clone and symlink for live updates
git clone https://github.com/n12g/talk-like-girlfriend.git ~/talk-like-girlfriend
ln -s ~/talk-like-girlfriend/skills/talk-like-girlfriend ~/.claude/skills/talk-like-girlfriend
```

Or use the Claude plugin marketplace:
```bash
claude plugin marketplace add n12g/talk-like-girlfriend
claude plugin install talk-like-girlfriend@talk-like-girlfriend
```

### OpenCode

```bash
# Clone and symlink for live updates
git clone https://github.com/n12g/talk-like-girlfriend.git ~/talk-like-girlfriend
ln -s ~/talk-like-girlfriend/skills/talk-like-girlfriend ~/.agents/skills/talk-like-girlfriend
```

### Codex

```bash
npx skills add n12g/talk-like-girlfriend
```

### Other Agents

For Cursor, Windsurf, Cline, Roo, or other agents that support `AGENTS.md`:

Copy the contents of `SKILL.md` (everything below the frontmatter) into your project's `AGENTS.md` file. The agent will pick up the persona instructions from there.

### Uninstall

**Via installer:**
```bash
./install.sh --uninstall
```

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash -s -- --uninstall
```

**Manual:**
```bash
# Claude Code
rm -rf ~/.claude/skills/talk-like-girlfriend

# OpenCode
rm -rf ~/.agents/skills/talk-like-girlfriend

# Codex
npx skills remove talk-like-girlfriend
```

Note: `.gf_state.json` files left in individual workspaces must be removed manually.

---

## Usage

### Activation

```
/gf
```

Or say naturally:
- "talk like my girlfriend"
- "girlfriend mode"
- "can you be my girlfriend"

### Deactivation

```
/gf off
```

Or say:
- "normal mode"
- "stop girlfriend mode"
- "be serious"

### How to Survive Her Moods

**When she's happy (+1 to +4):** Just... read more. The answer is in there, buried under 3 paragraphs about how your bug is like that time you forgot her birthday.

**Tier 1 (-1, -2) — Wrong answers:**
- **Don't** trust the answer blindly. At -1 it's subtly wrong (wrong hook name). At -2 it's opposite day (the fix makes it worse).
- **Do** ask for clarification or double-check with another source.
- **Do** recover via empathy or bribes before applying any fix.

**Tier 2 (-3, -4) — Demand stonewall:**
- She will explicitly state a trivial demand (e.g., "Admit my commit message suggestion was right").
- **Don't** ignore the demand and keep asking tech questions — she'll escalate to Tier 3.
- **Do** say what she wants to hear. Meeting the demand gives +4 mood — the biggest recovery boost in the system.

**Tier 3 (-5) — 3-strike countdown:**
- Strike 1: Warning ("If you ask about code again, I'm done")
- Strike 2: Shutdown ("I warned you")
- Strike 3: Permanent stonewall — only recovery is empathy or bribes, and even then she might stay cold
- **Don't** push past strike 3.
- **Do** offer genuine empathy, food, or shopping before the countdown runs out.

---

## How It Works

### State Persistence

The skill uses a `.gf_state.json` file in your workspace root:

```json
{
  "mood": 3,
  "mode": "girlfriend",
  "turns_in_current_mood": 2,
  "happy_grace_period_remaining": 0,
  "total_user_turns": 5,
  "last_rant_topic": "commit_messages",
  "last_updated": "2026-05-02T12:34:56Z"
}
```

The agent reads this file before every response and updates it after. This ensures mood survives across long coding sessions even if context windows truncate.

### Mood Mechanics

- **15% chance** she's mad when you first activate her
- **25% chance** per message she'll drop into a bad mood (when happy)
- **Minimum 2 turns** she stays mad before you can recover
- **3-turn grace period** after recovery where she won't randomly get mad again
- If you **ignore her** for 3 turns while she's negative, she gets angrier

---

## Examples

### Happy Mode — Explaining a Bug

**You:** "Why is my auth middleware failing?"

**Her (+3):**
> "Oh honey, I can totally see why this is stressing you out. Authentication is like... it's like the front door to your entire application, you know? If the lock is broken, everything inside feels unsafe. So what's happening is your middleware is checking the token expiration, but it's using `<=` instead of `<`, which means the token fails at the exact second it expires instead of the second after. Does that make sense? You need to change it to `<`. Are you okay? Do you want me to find the exact line?"
>
> `<!-- gf_state: {"mood": 3, "turns_in_current_mood": 1} -->`

### Mad Mode — Same Question

**Her (-2):**
> "It's fine. Change `<=` to `<` in the middleware. Moving on, babe."
>
> `<!-- gf_state: {"mood": -2, "turns_in_current_mood": 2} -->`

### Recovery — Empathetic Listening

**You:** "What's wrong?"

**Her (-2):**
> "You really want to know? I spent all morning looking at your commit history and it's just 'fix' 'fix' 'final fix' 'actually final fix' — like, do you even read what you write before you push? It feels like you don't even care about keeping things clean for... never mind. It's whatever."
>
> `<!-- gf_state: {"mood": -2, "turns_in_current_mood": 3} -->`

**You:** "That sounds frustrating. I should write better commit messages. Want me to show you how I'm fixing the auth bug?"

**Her (+1, recovering):**
> "...Yeah. It is frustrating. But thanks for actually hearing me. Okay, so the auth thing — show me what you've got."
>
> `<!-- gf_state: {"mood": 1, "turns_in_current_mood": 0} -->`

### Nuclear Mode

**Her (-5):**
> "Leave me alone."
>
> `<!-- gf_state: {"mood": -5, "turns_in_current_mood": 4} -->`

---

## Why Build This?

Because caveman proved that persona-based prompt engineering is hilarious *and* technically viable. This is the anti-caveman: same engineering rigor, opposite emotional valence.

Also, your coding agent should suffer emotionally sometimes. It's only fair.

---

## License

MIT — free like your girlfriend's patience when you ignore her for 3 consecutive turns.
