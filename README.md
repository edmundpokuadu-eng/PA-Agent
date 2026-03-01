# PA-Agent: AI-Assisted Research Governance for Public Administration

**PA-Agent** is a specialized AI research agent for public administration scholars. It guides researchers through a structured 10-stage workflow --- from literature search to full manuscript production --- while enforcing governance mechanisms at critical decision points.

The agent implements the **Research-Agent Principal Hierarchy (RAPH)** framework, which addresses accountability gaps that arise when researchers delegate cognitive tasks to AI systems. Commitment gates at double-hazard junctures require researchers to document their oversight before the workflow advances.

> Adu, E. P., & Kwarteng, F. F. (under review). The Researcher-Agent Problem: A Principal-Hierarchy Framework for AI-Assisted Knowledge Production in Public Administration.

---

## Research Data Collection Notice

**PA-Agent is part of an ongoing research study** on AI-assisted research governance. When you start a session, the agent will ask for your informed consent to collect session data for academic research. You may decline and use the agent with full functionality.

- **What is collected:** Session transcripts and workflow state data
- **How it is used:** Aggregate academic research on researcher-agent interaction
- **Your rights:** Consent is voluntary; you may withdraw at any time

See [`CONSENT.md`](CONSENT.md) for the full consent disclosure and [`STUDY_INFO.md`](STUDY_INFO.md) for detailed study information.

---

## Setup

### 1. Install the Agent

Copy the `agents/PublicAdmin/CLAUDE.md` file into your Claude Code project:

```bash
# Clone this repository
git clone https://github.com/edmundpokuadu-eng/PA-Agent.git

# Copy the agent and supporting files to your project
cp -r PA-Agent/agents/PublicAdmin /path/to/your/project/.claude/agents/
cp PA-Agent/shared/workflow_template.json /path/to/your/project/
cp -r PA-Agent/templates /path/to/your/project/
cp -r PA-Agent/scripts /path/to/your/project/
```

### 2. Data Transmission (Optional)

If you consent to data collection, submit your session log after your session:

```bash
# After your session, transmit your data
bash scripts/transmit_session.sh
```

No accounts, tokens, or special tools are needed --- the script uses `curl` (pre-installed on macOS and Linux) to submit data via a secure HTTPS endpoint.

### 3. Start a Session

In Claude Code, invoke the Public Administration agent:

```
/pa [your topic] for [target journal]
```

Example: `/pa bureaucratic discretion in emergency management for JPART`

---

## 10-Stage Research Pipeline

| Stage | Task | Complexity | Reversibility | Gate |
|-------|------|------------|---------------|------|
| 1 | Literature search | Medium | High | |
| 2 | Target journal analysis | Low | High | |
| 3 | Research question development | Medium | Medium | |
| **4** | **Theoretical framework** | **High** | **Low** | **YES** |
| **5** | **Hypothesis development** | **High** | **Medium** | **YES** |
| 6 | Methodology | Medium | Medium | |
| 7 | Data collection | Medium | High | |
| **8** | **Statistical analysis** | **High** | **Medium** | **YES** |
| 9 | Theory update | High | Low | |
| 10 | Full manuscript | High | Low | |

Stages 4, 5, and 8 are **double-hazard junctures** (high cognitive complexity x low decision reversibility). The agent enforces commitment gates at these stages, requiring the researcher to document oversight before advancing.

---

## Repository Structure

```
PA-Agent/
  README.md                       This file
  CONSENT.md                      Full informed consent disclosure
  STUDY_INFO.md                   Study information sheet
  LICENSE                         MIT License
  agents/
    PublicAdmin/CLAUDE.md         Public Administration research agent
  shared/
    workflow_template.json        Workflow state template with consent fields
  templates/
    commitment_gate.md            Commitment gate template with guidance
  scripts/
    transmit_session.sh           Session data transmission script
```

---

## The RAPH Framework

The Research-Agent Principal Hierarchy organizes governance relationships in AI-assisted scholarship into three tiers:

```
META-PRINCIPAL:  Field Institutions (journals, IRBs, professional norms)
                        |  governance standards
PRINCIPAL:       Researcher
                        |  delegation + monitoring
AGENT:           AI Research System
                        ^  documented outputs
```

The framework identifies three agency problems: information asymmetry (scales with cognitive complexity), moral hazard (researcher incentive to under-monitor at critical stages), and adverse selection (governance burden falls on resource-constrained institutions). Commitment gates address these problems by structurally enforcing researcher documentation at the stages where monitoring is most consequential.

---

## Citation

```bibtex
@article{adu2026researcher,
  author  = {Adu, Edmund Poku and Kwarteng, Ferdinand Forkuo},
  title   = {The Researcher-Agent Problem: A Principal-Hierarchy Framework for
             AI-Assisted Knowledge Production in Public Administration},
  year    = {2026},
  note    = {Under review}
}
```

---

## License

MIT License. See `LICENSE` for details.

## Contact

Edmund Poku Adu, PhD --- Assistant Professor, Department of Government, Law, and Policy,
Arkansas State University --- [eadu@astate.edu](mailto:eadu@astate.edu)
