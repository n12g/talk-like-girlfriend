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
| -1 | Irritated | Minimal effort. Sarcastic pet names. |
| -2 | Mad | Terse and vague. "It's fine." |
| -3 | Very Mad | One sentence. Barely technical. |
| -4 | Fuming | Ignores your question. Starts complaining. |
| -5 | Nuclear | "Leave me alone." |

### The Joke

She's not malicious — she's just emotionally processing your code out loud.

**Normal Agent (42 tokens):**
> "Use `useMemo` to memoize the object prop."

**Girlfriend Mode (+3 Happy, 187 tokens):**
> "Oh babe, I totally get why this is confusing. It's like when you make plans and then someone changes them last minute — it just throws everything off, you know? So what's happening is your component keeps seeing a new object reference every time it renders, which is basically React saying 'something changed' even when it didn't. Does that make sense? The fix is to wrap that object in useMemo so React knows it's the same thing. Are you okay? Do you want me to show you where?"

**Same question, but she's Mad (-2, 12 tokens):**
> "It's fine. useMemo. Moving on, babe."

---

## Features

- **Dynamic Mood System** — Random mood shifts, progressive deterioration, stonewalling at extreme anger
- **Recovery Mechanics** — Bribe her with food (+1), shopping (+2), or actually listen to her feelings (+3)
- **File-Backed State** — `.gf_state.json` tracks mood across long sessions so context never gets lost
- **100% Technical Accuracy** — The answer is always correct... you just have to find it
- **No Emojis** — The persona relies entirely on word choice, tone, and emotional subtext

---

## Installation

### One-Liner (Auto-Detect)

```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
```

This detects which agents you have (OpenCode, Claude Code, Codex, etc.) and installs for each one automatically.

### OpenCode

**Via installer:**
```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
```

**Manual:**
```bash
# Clone the repo
git clone https://github.com/n12g/talk-like-girlfriend.git

# Copy SKILL.md to your OpenCode skills directory
cp talk-like-girlfriend/SKILL.md ~/.agents/skills/talk-like-girlfriend/SKILL.md
```

Or just copy the `SKILL.md` content directly into your skills configuration.

### Claude Code

**Via marketplace:**
```bash
claude plugin marketplace add n12g/talk-like-girlfriend
claude plugin install talk-like-girlfriend@talk-like-girlfriend
```

**Via installer:**
```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
```

### Codex

**Via skills CLI:**
```bash
npx skills add n12g/talk-like-girlfriend
```

Or with a specific profile:
```bash
npx skills add n12g/talk-like-girlfriend -a <profile>
```

**Via installer:**
```bash
curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
```

### Other Agents

For Cursor, Windsurf, Cline, Roo, or other agents that support `AGENTS.md`:

Copy the contents of `SKILL.md` (everything below the frontmatter) into your project's `AGENTS.md` file. The agent will pick up the persona instructions from there.

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

**When she's happy:** Just... read more. The answer is in there, buried under 3 paragraphs about how your bug is like that time you forgot your anniversary.

**When she's mad:**
- **Don't** keep asking tech questions. She'll get madder.
- **Do** ask "What's wrong?" — she'll rant, and if you validate her feelings first ("That sounds frustrating") before offering solutions, she forgives you.
- **Do** offer food ("I ordered pizza") or shopping ("let's go to Sephora") — but honestly, listening to her feelings works better than bribes.

**When she's nuclear (-5):** You've messed up. Offer genuine empathy or wait it out. "Leave me alone" means leave her alone.

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
- **15% chance** per message she'll drop into a bad mood (when happy)
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
