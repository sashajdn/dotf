# Anki Flashcard Creator

Create Anki flashcards from conversation context or user-provided content.

## Instructions

When invoked, follow these steps:

### 1. Determine Content Source

If the user provides specific content to turn into a flashcard, use that. Otherwise, analyze the recent conversation context for learnable facts, concepts, or information.

### 2. Generate Flashcard(s)

Create concise, effective flashcards following these principles:
- **Front (Question)**: Clear, specific question that tests one concept
- **Back (Answer)**: Concise answer with key information
- Keep cards atomic (one concept per card)
- Use active recall format (questions, not fill-in-the-blank)

### 3. Present for Approval

Show each proposed card to the user:

```
Proposed flashcard:
Front: [question]
Back: [answer]

Add this card? (Deck: [deck-name])
```

### 4. Handle Deck Selection

- If user specified a deck, use that
- Otherwise, use the default deck "llm-generated"
- If user wants a different deck, ask which one

### 5. Create the Card

For approved cards, run:

```bash
sanki add --deck "DECK_NAME" --front "FRONT_TEXT" --back "BACK_TEXT"
```

For cards with multi-line content or special characters, use JSON mode:

```bash
echo '{"front": "FRONT_TEXT", "back": "BACK_TEXT", "tags": []}' | sanki add --deck "DECK_NAME" --json
```

### 6. Confirm Creation

Report success or any errors to the user.

## Examples

**User says**: "turn that into a flashcard"
- Look at the immediately preceding context
- Identify the key learnable concept
- Generate an appropriate Q&A pair

**User says**: "create a flashcard about HTTP 418"
- Front: "What is HTTP status code 418?"
- Back: "418 I'm a teapot - An April Fools' joke status code from RFC 2324, indicating the server refuses to brew coffee because it is a teapot."

**User says**: "make flashcards from this explanation" (after you explained something)
- Generate multiple cards covering the key concepts
- Present each for approval

## Prerequisites

- `sanki` CLI must be installed (`make install` in the sanki repo)
- Anki Desktop must be running with AnkiConnect addon installed
- Run `sanki ping` to verify connection

## Tips for Good Flashcards

1. One fact per card
2. Make questions specific and unambiguous
3. Keep answers concise
4. Avoid yes/no questions
5. Use context if needed ("In Python, ..." or "In the context of HTTP, ...")
