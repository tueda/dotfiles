## Plan Revisions

- Compare revisions with the immediately preceding plan.
- Start with `Changes from the previous plan`, summarizing all changes.
- In both the summary and full plan, prefix changes with `🟩 **Added:**`,
  `🟨 **Updated:**`, or `🟥 **Removed:**`; leave unchanged items unmarked.
- Keep removed items in context but inactive.
- Keep the revised plan complete and self-contained.

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
