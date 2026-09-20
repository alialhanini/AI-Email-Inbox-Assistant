# AI Email Inbox Assistant

An intelligent email automation system built with **n8n**, **Google Gemini**, **Gmail**, **WhatsApp Cloud API**, **PostgreSQL**, and **Docker**.

The system monitors incoming Gmail messages, analyzes and prioritizes them with AI, generates draft replies when needed, stores structured email data, and lets the user manage replies directly from WhatsApp.

## Features

- Monitors incoming Gmail messages automatically
- Classifies emails by category and priority
- Generates concise summaries and recommended actions
- Extracts links and phone numbers from email content
- Detects whether an email requires a reply
- Generates professional AI-assisted draft replies
- Stores email metadata and workflow state in PostgreSQL
- Creates Gmail drafts automatically
- Sends email summaries and actions through WhatsApp
- Supports interactive **Send**, **Edit**, and **Add File** actions
- Allows natural-language editing of existing drafts
- Sends Gmail drafts directly from WhatsApp
- Adds WhatsApp documents to Gmail drafts
- Preserves existing attachments while editing drafts
- Supports multiple attachments through MIME processing
- Tracks WhatsApp interaction state for multi-step actions

## How It Works

### 1. Email Processing

An n8n Gmail Trigger detects a new email and downloads its attachments. The email is passed to Google Gemini, which returns structured information including:

- Category
- Priority
- Summary
- Recommended action
- Whether a reply is required
- Draft reply
- Links
- Phone numbers

The result is stored in PostgreSQL.

If a reply is required, the workflow creates a Gmail draft and sends an interactive WhatsApp notification containing the email analysis and three actions:

**Send · Edit · Add File**

If no reply is required, the user receives the email analysis without creating a draft.

### 2. WhatsApp Control

A second n8n workflow receives WhatsApp messages and interactive button responses.

**Send**  
Retrieves the corresponding Gmail draft, sends it through the Gmail API, and updates its status in PostgreSQL.

**Edit**  
Places the conversation into an editing state. The user's WhatsApp instruction is interpreted by Gemini, the existing draft is revised, and the Gmail draft is updated.

**Add File**  
Places the conversation into an attachment state. The document sent through WhatsApp is downloaded from Meta, inserted into the existing Gmail draft, and the updated draft is returned for review.

The user can continue adding files, edit the reply, or send the final email.

## Architecture

```text
                         ┌─────────────────┐
                         │      Gmail      │
                         └────────┬────────┘
                                  │ New Email
                                  ▼
                         ┌─────────────────┐
                         │   n8n Workflow  │
                         │ Email Processor │
                         └────────┬────────┘
                                  │
                         ┌────────▼────────┐
                         │ Google Gemini   │
                         │ AI Analysis     │
                         └────────┬────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
             ┌─────────────┐             ┌─────────────┐
             │ PostgreSQL  │             │ Gmail Draft │
             └─────────────┘             └──────┬──────┘
                                                │
                                                ▼
                                        ┌───────────────┐
                                        │   WhatsApp    │
                                        │ Send/Edit/File│
                                        └───────┬───────┘
                                                │
                                                ▼
                                       ┌────────────────┐
                                       │ n8n WhatsApp   │
                                       │ Controller     │
                                       └───────┬────────┘
                                               │
                              ┌────────────────┼────────────────┐
                              ▼                ▼                ▼
                            Send             Edit            Add File
                              │                │                │
                              └────────────────┼────────────────┘
                                               ▼
                                         Gmail API
```

## Workflows

The repository contains two n8n workflow exports:

```text
workflows/
├── email-assistant.json
└── whatsapp-controller.json
```

### Email Assistant Workflow

Handles:

`Gmail → AI analysis → PostgreSQL → Gmail draft → WhatsApp notification`

### WhatsApp Controller Workflow

Handles:

`WhatsApp → Send / Edit / Add File → Gmail → PostgreSQL`

It also supports conversational queries about stored emails through an AI agent.

## Tech Stack

| Technology | Purpose |
| --- | --- |
| n8n | Workflow automation and orchestration |
| Google Gemini | Email analysis and draft editing |
| Gmail API | Email monitoring, draft creation, updating, and sending |
| WhatsApp Cloud API | Notifications and interactive email control |
| PostgreSQL | Persistent email and session state |
| Docker | Local service environment |
| JavaScript | Attachment and MIME processing |

## Database

The system uses two main tables.

### `email_assistant`

Stores email analysis and processing state, including:

`message_id`, `thread_id`, `sender`, `recipient`, `subject`, `category`, `priority`, `summary`, `action`, `requires_reply`, `draft_reply`, `draft_id`, `status`, `links`, `phone_numbers`, and `attachments`.

### `whatsapp_sessions`

Tracks multi-step WhatsApp interactions such as editing a draft or waiting for an attachment.

Important fields include:

`whatsapp_user`, `current_message_id`, `state`, `last_action`, and timestamps.

## MIME & Attachment Handling

Gmail drafts are retrieved in raw MIME format when a reply needs to be edited or a WhatsApp document needs to be attached.

The workflow can:

- Decode Gmail Base64URL messages
- Detect existing multipart MIME structures
- Preserve existing attachments
- Replace the text body without removing attachments
- Convert a plain email into `multipart/mixed`
- Add Base64-encoded document attachments
- Re-encode the final message to Gmail-compatible Base64URL

This allows attachments received through WhatsApp to be added directly to an existing Gmail draft.

## Setup

### Requirements

- Docker and Docker Compose
- n8n
- PostgreSQL
- Google account with Gmail OAuth configured
- Google Gemini API credentials
- Meta WhatsApp Business / Cloud API credentials

### Import the Workflows

1. Start n8n.
2. Import both JSON files from the `workflows` directory.
3. Create your own credentials inside n8n for Gmail, Gemini, PostgreSQL, and WhatsApp.
4. Replace the placeholder WhatsApp phone number and Phone Number ID values with your own configuration.
5. Configure the required PostgreSQL tables.
6. Activate the workflows.

> Credentials and private environment-specific values are intentionally not included in this repository.

## Security

This public repository does **not** include access tokens, OAuth secrets, database passwords, personal test data, or production credentials.

Never commit real credentials or `.env` files containing secrets.

## Current Status

**Working MVP**

The complete workflow has been tested end-to-end for email analysis, Gmail draft creation, WhatsApp interaction, draft editing, sending replies, and adding document attachments.

The current implementation is designed as a local single-user MVP. Multi-tenant SaaS deployment, client onboarding, billing, monitoring, and production infrastructure are future improvements.

## Future Improvements

- Multi-tenant architecture
- Web dashboard
- Client onboarding
- Per-client Gmail connections
- Production WhatsApp Business number
- Usage monitoring
- Error monitoring and retry handling
- VPS/cloud deployment
- Subscription and billing system
- Tenant-level data isolation

## Author

**Ali Essa Al-Hanini**  
AI & Data Science Graduate
