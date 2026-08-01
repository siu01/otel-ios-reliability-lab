# E004 results: single-owner retry kept recovery and removed amplification

## Result

Both stateless-exporter runs recovered all 100 logical spans exactly once.

| Collector delay | Completed failures | Request body sizes | Total received | Duplicates | Missing |
|---:|---:|---|---:|---:|---:|
| 8 s | 1 | 27,818 → 27,818 | 100 | 0 | 0 |
| 10 s | 2 | 27,818 → 27,818 → 27,818 | 100 | 0 | 0 |

The post-window persistence directory was empty in both runs, and all 100 trace
ID/span ID pairs appeared exactly once.

## Direct ten-second intervention comparison

The E003 and E004 ten-second runs each completed two connection-refused failures
before one success. They differed in whether the decorated exporter retained its
own failed spans.

| Exporter beneath persistence | HTTP body sequence | Total received | Multiplicity |
|---|---|---:|---:|
| Official stateful OTLP/HTTP | 27,818 → 55,418 → 83,018 | 300 | 3x |
| Lab stateless OTLP/HTTP | 27,818 → 27,818 → 27,818 | 100 | 1x |

Both used the official instant persistence preset, disabled explicit provider
flush, instrumented the same official `BaseHTTPClient`, generated 100 spans, and
waited through the same nominal Collector delay and capture window.

## Hypothesis decision

The single-retry-owner hypotheses passed in both registered runs:

- request bodies did not grow after failures;
- all logical spans were eventually received;
- no sequence or trace/span identity was duplicated;
- persistence files were removed after successful delivery.

This supplies an intervention, not only a correlation, for the dual-retry
mechanism found in E003.

## Scope

The lab stateless exporter is a mechanism proof. It serializes the supplied
`SpanData` as an OTLP protobuf trace request and implements the timeout/result
contract needed by this experiment. It does not yet claim full feature parity
with the official exporter, including environment/config headers, compression,
exporter metrics, all shutdown behavior, or production hardening.

The result therefore supports the design rule “one layer should own retry state”
under these conditions. It does not recommend dropping the lab exporter into a
production app without further implementation and compatibility tests.
