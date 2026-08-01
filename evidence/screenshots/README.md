# Screenshot evidence

Screenshots make lifecycle state and UI output inspectable, but they are not raw
delivery measurements.

Each committed PNG must have a same-stem Markdown sidecar recording:

- Experiment ID and state.
- Source commit.
- Simulator or physical device.
- Capture command.
- SHA-256 digest.
- What the image can and cannot support.

Do not edit evidence images after capture. If annotation is needed, preserve the
original and commit an explicitly suffixed derivative.

