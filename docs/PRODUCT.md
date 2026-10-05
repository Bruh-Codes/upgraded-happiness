# Product direction and implementation handoff

Build a tenant-aware voice support assistant for business websites, restaurant information, documentation and shopping assistance. The owner builds UI. Salesforce's Piper widget inspires the website entry point and voice interaction. LiveAvatar's language demo is a reference for fluid speech, lip sync, listening and interruption.

Own the business platform: tenant configuration, knowledge ingestion/retrieval, allowed tools, escalation, sessions and usage accounting. Own the animation worker and media delivery where feasible. OpenAI or another LLM may be used independently; LiveAvatar is an optional renderer adapter with no automatic paid fallback.

Services:
1. API/control backend and database: tenants, agents, sources, avatar/voice configs, signed sessions, limits.
2. Conversation worker: streaming ASR, retrieval, answer policy, tool calls and streaming TTS.
3. GPU animation worker: portrait/audio input, incremental video, persistent model and admission control.
4. Media transport: encoder, WebRTC signaling/SFU/TURN as needed and synchronized playback.

Start with grounded answers and support ticket handoff. Restaurant bookings and cart suggestions are later integrations. Require explicit confirmation before consequential actions. Do not collect payment details in the avatar conversation.

Implement interfaces independently of the animator:
- create session -> session ID, transport credentials and chosen worker
- send audio -> timestamped PCM chunks
- avatar output -> video frame/audio timestamps, turn ID
- interrupt -> cancel current turn, flush buffers, return to listening
- end session -> release worker and record usage

The earlier SYSTEM_DESIGN and ANIMATION_ALTERNATIVES documents are retained as historical design notes. This document and REALTIME supersede statements that own GPU rendering is deferred or no model was tested. The repository is a reproducible renderer experiment, not the completed support product.
