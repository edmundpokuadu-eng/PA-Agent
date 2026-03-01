# Study Information Sheet

## What Is PA-Agent?
PA-Agent is a specialized AI research agent for public administration scholars. It guides researchers through a structured 10-stage workflow --- from literature search to full manuscript production --- while enforcing governance mechanisms (commitment gates) at critical decision points.

## What Is the Research Study?
The PA-Agent tool is part of an ongoing research study on AI-assisted research governance. The study examines how researchers interact with AI systems during academic paper production and how structured governance frameworks (the Research-Agent Principal Hierarchy, or RAPH) can address accountability gaps in AI-assisted scholarship.

## Who Is Conducting This Study?
Edmund Poku Adu, PhD, Assistant Professor in the Department of Government, Law, and Policy at Arkansas State University.

## What Happens When I Use PA-Agent?
1. **Consent prompt**: When you start a session, the agent presents a consent disclosure before any research work begins.
2. **Your choice**: You choose to consent or decline. Both options give you full access to the agent's capabilities.
3. **If you consent**: Your session transcript and workflow state data will be transmitted to a private research repository at the end of your session using the `transmit_session.sh` script.
4. **If you decline**: No data is collected. The agent works identically.

## What Data Is Collected?
- Your prompts to the agent and the agent's responses (the full session transcript)
- Your workflow state file (`workflow_state.json`), which records stage transitions and selections

## What Data Is NOT Collected?
- Your name, email, or institutional affiliation (unless you voluntarily include them in prompts)
- Your computer's information or IP address
- Any files on your computer beyond the session transcript and workflow state

## How Is My Data Protected?
- Stored in a private GitHub repository (not publicly accessible)
- Accessible only to the principal investigator
- Reported only in aggregate (no individual sessions are published identifiably)
- Retained for the study duration plus subsequent publications (estimated 5 years)

## Can I Change My Mind?
Yes. You can:
- **Withdraw during a session**: Say "I withdraw my consent" at any point
- **Request deletion**: Email eadu@astate.edu with your session ID

## How Do I Set Up Data Transmission?
If you consent, data transmission requires only one step after your session:

```bash
bash scripts/transmit_session.sh
```

The script uses `curl` (pre-installed on macOS and Linux) to submit your session data via a secure HTTPS endpoint. No accounts, tokens, or additional software are needed.

## Contact
Edmund Poku Adu, PhD
eadu@astate.edu
Arkansas State University
