# PA-Agent: Governance Framework for AI-Assisted Research in Public Administration

**PA-Agent** provides the Research-Agent Principal Hierarchy (RAPH) governance framework
and commitment gate templates for public administration scholars who use AI agents in
their research workflows. The framework addresses the principal-agent accountability
gaps that arise when researchers delegate cognitive tasks to AI systems.

> Adu, E. P. (under review). The Researcher-Agent Problem: A Principal-Hierarchy
> Framework for AI-Assisted Knowledge Production in Public Administration.

---

## The RAPH Framework

The Research-Agent Principal Hierarchy organizes the governance relationships in
AI-assisted scholarship into three tiers:

```
META-PRINCIPAL:  Field Institutions (journals, IRBs, ASPA, professional norms)
                        |  governance standards
PRINCIPAL:       Researcher
                        |  delegation + monitoring
AGENT:           AI Research System
                        ^  documented outputs
```

The framework identifies three agency problems that arise in AI-assisted research:

1. **Information Asymmetry** — scales with task cognitive complexity; the researcher
   cannot observe the AI agent's inferential process
2. **Moral Hazard** — the researcher's incentive to under-monitor increases at exactly
   the stages where monitoring is most consequential
3. **Adverse Selection** — the governance burden falls disproportionately on researchers
   at resource-constrained institutions

These agency problems compound at **double-hazard junctures** (high cognitive complexity
x low decision reversibility), producing the framework's central finding: tiered
monitoring protocols fail when left to researcher discretion at exactly the stages where
they are most needed. Commitment gates must be structurally enforced.

---

## 10-Stage Research Pipeline

| Stage | Task | Complexity | Reversibility | Gate Required |
|-------|------|------------|---------------|---------------|
| 1 | Literature search | Medium | High | No |
| 2 | Target journal analysis | Low | High | No |
| 3 | Research question development | Medium | Medium | No |
| **4** | **Theoretical framework** | **High** | **Low** | **YES** |
| **5** | **Hypothesis/proposition development** | **High** | **Medium** | **YES** |
| 6 | Methodology | Medium | Medium | No |
| 7 | Data preparation | Medium | High | No |
| **8** | **Statistical analysis** | **High** | **Medium** | **YES** |
| 9 | Theory update | High | Low | No |
| 10 | Full manuscript | High | Low | No |

Stages 4, 5, and 8 are **double-hazard junctures**. The commitment gate template
(below) enforces researcher documentation at these stages before the workflow advances.

---

## Commitment Gate Template

At Stages 4, 5, and 8, the researcher completes the following structured memo before
the AI agent advances to the next stage:

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

The full template with additional guidance is in `templates/commitment_gate.md`.

---

## Paper and Replication Materials

The `paper/` directory contains the full manuscript and supporting materials:

```
paper/
  par_paper_main.tex       Manuscript (LaTeX)
  par_paper_main.pdf       Compiled PDF
  references.bib           Bibliography
  title_page.tex           Title page (blind review)
  title_page.pdf           Compiled title page
  session_logs/
    workflow_state.json    Workflow state at each stage transition
```

The manuscript documents a complete 10-stage AI-assisted research pipeline as a single
instrumental case study, testing the RAPH framework's four theoretical propositions
against verbatim session logs. Full session transcripts available to verified
researchers on request.

---

## Citation

```bibtex
@article{adu2026researcher,
  author  = {Adu, Edmund Poku},
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

Edmund Poku Adu, PhD — Assistant Professor, Department of Government, Law, and Policy,
Arkansas State University — [eadu@astate.edu](mailto:eadu@astate.edu)
