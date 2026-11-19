## Plan Revisions

These rules apply only to chat replies that present a revised plan.

- Compare the revised plan with the immediately preceding version.
- Begin the reply with `Changes from the previous plan` and summarize all
  changes.
- In both the change summary and the full plan shown in chat, prefix changed
  items with `🟩 **Added:**`, `🟨 **Updated:**`, or `🟥 **Removed:**`. Leave
  unchanged items unmarked.
- In chat, retain removed items for context only and clearly mark them as
  inactive.
- Keep the revised plan complete and self-contained.

Do not carry this revision markup into deliverables, including saved plan
files, reports, or repository documents. Deliverables should contain only the
current, complete version, with no revision summary, change markers, or removed
items unless explicitly requested.

## Disk Space Management

For operations expected to consume substantial disk space, such as repeated
container builds:

- Before starting, estimate peak usage, including temporary files and caches.
  Check free space on the target filesystems and any underlying host storage.
- Leave ample headroom for uncertainty, the OS, and other applications.
- Monitor usage and avoid accumulating unnecessary trial artifacts.
- If headroom is at risk, do not start the operation; if already running, stop
  it safely. Report the issue. Do not delete unrelated data to make room.

Skip these checks for routine work unless substantial disk growth is expected.
