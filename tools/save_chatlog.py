"""Write the user and assistant text of a Claude Code transcript (.jsonl) as Markdown.
Tool calls, tool output, thinking and system reminders are left out.

Transcripts are in %USERPROFILE%\\.claude\\projects\\D--3DPrints\\<session id>.jsonl

Usage: python tools/save_chatlog.py <transcript.jsonl> <output.md> [title]

Private names (hosts, paths) are replaced using tools/chatlog_redact.txt if it exists.
That file is git-ignored. One rule per line: regex<TAB>replacement. Lines starting with # are skipped.
"""
import json
import re
import sys
from pathlib import Path

REDACT_FILE = Path(__file__).with_name("chatlog_redact.txt")


def messages(lines):
    """Yield (speaker, timestamp, text) for each chat message in the transcript lines."""
    for line in lines:
        d = json.loads(line)
        if d.get("type") not in ("user", "assistant") or d.get("isSidechain") or d.get("isMeta") \
                or d.get("isCompactSummary"):
            continue
        c = d["message"]["content"]
        texts = [c] if isinstance(c, str) else [b["text"] for b in c if b.get("type") == "text"]
        texts = [re.sub(r"<system-reminder>.*?</system-reminder>", "", t, flags=re.S).strip() for t in texts]
        texts = [t for t in texts if t and not t.startswith("<")]  # drops command and hook wrappers
        if texts:
            yield ("User" if d["type"] == "user" else "Claude",
                   d.get("timestamp", "")[:16].replace("T", " "), "\n\n".join(texts))


def to_markdown(lines, title):
    out = [f"# {title}", ""]
    for who, when, text in messages(lines):
        out += [f"## {who} ({when})", "", text, ""]
    return "\n".join(out)


def redact(text, rules):
    for pattern, replacement in rules:
        text = re.sub(pattern, replacement, text)
    return text


def load_rules(path):
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    return [tuple(l.split("\t", 1)) for l in lines if l.strip() and not l.startswith("#")]


def selftest():
    lines = [json.dumps(x) for x in [
        {"type": "user", "timestamp": "2026-10-24T19:26:00Z", "message": {"content": "hi<system-reminder>x</system-reminder>"}},
        {"type": "assistant", "timestamp": "2026-10-24T19:27:00Z", "message": {"content": [
            {"type": "thinking", "thinking": "secret"}, {"type": "text", "text": "hello"}]}},
        {"type": "user", "message": {"content": [{"type": "tool_result", "content": "out"}]}},
        {"type": "user", "isMeta": True, "message": {"content": "meta"}},
        {"type": "mode", "mode": "normal"},
    ]]
    assert redact("host qnap-x here", [(r"qnap-\w+", "<NAS>")]) == "host <NAS> here"
    assert list(messages(lines)) == [("User", "2026-10-24 19:26", "hi"), ("Claude", "2026-10-24 19:27", "hello")]


def main():
    selftest()
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    with open(sys.argv[1], encoding="utf-8") as f:
        md = redact(to_markdown(f, sys.argv[3] if len(sys.argv) > 3 else "Chat log"), load_rules(REDACT_FILE))
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        f.write(md)
    print(md.count("\n## "), "messages")


if __name__ == "__main__":
    main()
