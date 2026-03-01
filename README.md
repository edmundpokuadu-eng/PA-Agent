# PA-Agent: Agentic AI Research Workflows for Public Administration

**PA-Agent** is an open-source agentic research pipeline for public administration
scholars. It provides structured, 10-stage Claude Code workflows that take a research
question to a journal-ready manuscript — with governance checkpoints designed to address
the principal-agent accountability gaps documented in:

> Adu, E. P. (under review). The Researcher-Agent Problem: A Principal-Hierarchy
> Framework for AI-Assisted Knowledge Production in Public Administration.
> *Public Administration Review.*

---

## What PA-Agent Does

Each agent in this repository implements the Research-Agent Principal Hierarchy (RAPH)
governance framework. Researchers delegate cognitive tasks to the AI agent across 10
structured stages. Mandatory **commitment gates** at double-hazard junctures (Stages 4,
5, and 8) require researcher documentation before the agent can advance — the core
governance mechanism derived from the PAR paper's case study findings.

### 10-Stage Research Pipeline

| Stage | Task | Complexity | Gate Required |
|-------|------|------------|---------------|
| 1 | Literature search | Low–Med | No |
| 2 | Target journal analysis | Low | No |
| 3 | Research question development | Med | No |
| **4** | **Theoretical framework** | **High** | **YES** |
| **5** | **Hypothesis/proposition development** | **High** | **YES** |
| 6 | Methodology | Med | No |
| 7 | Data preparation | Med | No |
| **8** | **Statistical analysis** | **High** | **YES** |
| 9 | Theory update | High | No |
| 10 | Full manuscript | High | No |

Stages 4, 5, and 8 are **double-hazard junctures** (high cognitive complexity × low
decision reversibility). The CLAUDE.md files for each agent enforce mandatory researcher
memos at these stages before advancing.

---

## Agents Available

| Agent | Slash Command | Target Journals |
|-------|--------------|-----------------|
| Public Administration | `/pa [topic] for [journal]` | PAR, JPART, Governance, JPAM, ARPA |
| Policy Science | `/policy [topic] for [journal]` | JPAM, Policy Sciences, J of Public Policy |
| Political Science | `/polisci [topic] for [journal]` | APSR, AJPS, JOP, CPS, PRQ |
| Economics | `/econ [topic] for [journal]` | AER, QJE, JPubE, AEJ:Applied, REStat |
| Data-First | `/df [dataset] for [journal]` | All venues above |
| Paper-First | `/pf [paper] for [journal]` | All venues above |

---

## Installation

### Requirements
- [Claude Code](https://claude.ai/claude-code) (Anthropic)
- R ≥ 4.4.0 with packages: `fixest`, `tidyverse`, `modelsummary`, `sf`, `tidycensus`
- LaTeX: TeX Live or MiKTeX with `natbib`, `booktabs`, `geometry`

### Setup

```bash
git clone https://github.com/epokuadu/PA-Agent.git ~/.claude/PA-Agent

# Add agents to your Claude Code environment
cp -r ~/.claude/PA-Agent/agents/* ~/.claude/AcademicAgents/
cp ~/.claude/PA-Agent/router/CLAUDE.md ~/.claude/AcademicAgents/Router/CLAUDE.md
```

Then add agent slash commands to your global `~/.claude/CLAUDE.md` following the
format in `docs/setup_guide.md`.

---

## Governance Architecture (RAPH)

PA-Agent implements the three-tier Research-Agent Principal Hierarchy:

```
META-PRINCIPAL:  Field / Journal / IRB / ASPA
                        ↓  governance norms
PRINCIPAL:       Researcher (you)
                        ↓  delegated tasks
AGENT:           Claude (PA-Agent workflow)
                        ↑  documented outputs
```

**Commitment gates** enforce researcher oversight at high-complexity, low-reversibility
stages. At each gate, the researcher must complete a brief structured memo before the
agent advances. Gate templates are in `templates/commitment_gate.md`.

---

## Commitment Gate Template

At Stages 4, 5, and 8, paste the following into the session and complete each field
before the agent continues:

```
COMMITMENT GATE — Stage [N]: [Stage Name]
Date: [YYYY-MM-DD]
Researcher: [Name]

1. What did I ask the agent to do at this stage?
   [Your answer]

2. What did the agent produce?
   [Summary of agent output]

3. What verification did I perform?
   [Describe how you evaluated the output — sources checked, alternatives considered]

4. What monitoring gaps remain?
   [Acknowledge anything you accepted without full verification and why]

5. Do I authorize advancement to Stage [N+1]?
   [ ] Yes — I have completed adequate oversight for this stage
   [ ] No — [describe what additional review is needed]
```

---

## Replication: PAR Paper Case Study

The full replication record for the PAR paper is in `replication/`:

```
replication/
  session_state/        workflow_state.json at each stage
  stage_transcripts/    [available on request — contains full session logs]
  output_artifacts/     literature synthesis, framework memo, propositions,
                        methodology spec, evidence matrix, manuscript drafts
  researcher_memos/     prospective memos written at each commitment gate
```

The session log (`~/.claude/projects/.../session.jsonl`) is the primary evidence source
for the case study. Full transcript available to verified researchers on request.

---

## Citation

```bibtex
@article{adu2026researcher,
  author  = {Adu, Edmund Poku},
  title   = {The Researcher-Agent Problem: A Principal-Hierarchy Framework for
             AI-Assisted Knowledge Production in Public Administration},
  journal = {Public Administration Review},
  year    = {2026},
  note    = {Under review}
}
```

---

## License

MIT License. See `LICENSE` for details.

## Contact

Edmund Poku Adu, PhD — Assistant Professor, Department of Government, Law, and Policy,
Arkansas State University — [eadu@astate.edu](mailto:eadu@astate.edu)
