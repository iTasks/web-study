## From Java EE to Quarkus and LLMs: Adam Bien’s Playbook for Boring, Future‑Proof Systems
---

- **Adam Bien**, an independent consultant and pioneer of zero dependencies in the enterprise world of Java, highlights the benefits of consistently using standards, regardless of whether they involve Java or existing patterns. He argues that by doing so, he managed to future-proof the systems he built, preparing them for the cloud era and even for the AI-Native era.

#### Key Takeaways
- Sticking to Vanilla Java, such as the standard library, Jakarta EE, and MicroProfile, with zero or very few dependencies can outlast trend‑driven stacks, simplify upgrades, and even make security and certifications easier.
- Quarkus managed to close the gap between Java standards and the cloud, achieving fast boot times, an improved developer experience, and even lower cloud bills while keeping external dependencies low.
- The usage of the simple vertical slicing imposed by the Boundary‑Control‑Entity‑Entity pattern, corroborated by publicly available Java specs, enables LLMs to generate production‑ready Java code.
- When working with LLMs for code generation, moving away from a monolithic configuration file to a set of lean, task‑specific skills `(e.g. microservices, CLIs, tests)` improves the reliability of the output on large codebases.
- OpenTelemetry, Java‑based GPU tooling like TornadoVM, and zero‑dependency Java 25 scripts open the door to observable, AI‑enabled Java systems that can run both in the big clouds and in sovereign on‑prem environments.
