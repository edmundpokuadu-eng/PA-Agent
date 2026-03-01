# Commitment Gate Template

**Use this template at Stages 4, 5, and 8 (double-hazard junctures).**

Copy the block below into the Claude Code session and fill in each field.
The agent will not advance to the next stage until the gate is completed.

---

```
COMMITMENT GATE — Stage [N]: [Stage Name]
Date: [YYYY-MM-DD]
Researcher: [Name]
Session ID: [e.g., PA_20260227_1400]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. DELEGATION RECORD
   What did I ask the agent to do at this stage?
   ↳ [Your answer — describe the task you delegated]

2. AGENT OUTPUT SUMMARY
   What did the agent produce?
   ↳ [Brief summary — what framework / propositions / analysis was returned?]

3. VERIFICATION PERFORMED
   How did I evaluate the agent's output?
   ↳ [Describe your review: sources checked, alternatives considered,
      logical chain examined, prior literature consulted, etc.]
   ↳ [Be specific — "I read it and it looked right" is not adequate
      verification at a double-hazard juncture]

4. MONITORING GAPS ACKNOWLEDGED
   What did I accept without full verification, and why?
   ↳ [Honest acknowledgment of what you did NOT check and your reason —
      time constraints, expertise limits, or genuine confidence based on
      stated verification above]

5. DOWNSTREAM COMMITMENT
   What decisions does this stage lock in for subsequent stages?
   ↳ [List what changes if this output is wrong — e.g., "All propositions,
      methodology, analysis, and manuscript structure follow from this framework"]

6. ADVANCEMENT AUTHORIZATION
   Do I authorize advancement to Stage [N+1]?

   [ ] YES — I have completed adequate oversight for the governance stakes
              of this stage and accept responsibility for the output

   [ ] NO  — [Describe what additional review is needed before advancing]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate signed: [Researcher signature / initials]
```

---

## Why This Gate Exists

The PAR paper (Adu 2026) documents that the Stage 4 framework commitment was accepted
with a single-character response ("1") — a pure moral hazard event at the highest-stakes,
lowest-reversibility decision point in the workflow. This gate was designed specifically
to prevent that failure by requiring researcher engagement *before* the agent advances,
not after outputs are already embedded in downstream stages.

**The gate works only if completed honestly.** A researcher who types placeholder answers
to advance quickly has replicated the moral hazard problem, not solved it.

---

## Gate Stages Reference

| Stage | Name | Why It Is a Gate |
|-------|------|-----------------|
| 4 | Theoretical Framework | Locks all propositions, methodology, analysis, and manuscript structure. The highest-commitment, lowest-reversibility decision in the workflow. |
| 5 | Propositions / Hypotheses | Locks the analytical targets that all subsequent analysis must address. Changing propositions after Stage 6 requires restarting data and analysis. |
| 8 | Statistical Analysis | The highest technical-complexity stage; errors here propagate directly into findings, discussion, and conclusions with no downstream detection opportunity. |
