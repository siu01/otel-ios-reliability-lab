# E002 results: explicit force flush was not required for amplification

## Result

Removing the app's `TracerProvider.forceFlush()` call did not remove duplicate
delivery under the eight-second instant-persistence outage.

| Generated | Unique received | Total received | Missing | Duplicates | Exact multiplicity |
|---:|---:|---:|---:|---:|---:|
| 100 | 100 | 300 | 0 | 200 | 3x |

Every sequence from 1 through 100 appeared three times, and the post-capture
persistence directory was empty.

## Hypothesis decision

The narrow hypothesis that explicit flush must race the scheduled persistence
worker was rejected. E001's instant runs used explicit flush and delivered 2x;
E002 disabled it and delivered 3x.

This result shifted the causal question from concurrency between two persistence
paths to retry state held by adjacent layers. Subsequent E003 instrumentation
showed two completed HTTP failures followed by a successful request whose body
contained three copies of the original span batch.

## Scope

E002 was a single fresh-install run and did not itself observe HTTP requests.
Its role is causal isolation: it demonstrates that application-level explicit
flush is not necessary for the behavior. The matching instrumented eight-second
result in E003 provides an independent 3x reproduction and request-level detail.
