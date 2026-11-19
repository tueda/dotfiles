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

## Git Commit Messages

Follow any commit message requirements explicitly given in the task prompt.
Otherwise, follow the project's conventions if specified. If neither specifies
a format, use Conventional Commits and the line limits below.

- Use `type(scope): description`, omitting the scope when it adds no useful
  context.
- Keep the subject on one line. Aim for 50 characters or fewer, including the
  prefix, and do not exceed 72.
- Separate the subject and body with a blank line.  Wrap body prose at 72
  characters. Do not break URLs or Git trailers just to fit the limit.
