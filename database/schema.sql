-- AI Email Inbox Assistant
-- PostgreSQL database schema

CREATE TABLE IF NOT EXISTS email_assistant (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    message_id TEXT NOT NULL UNIQUE,
    thread_id TEXT,
    sender TEXT,
    recipient TEXT,
    subject TEXT,
    category TEXT,
    priority TEXT,
    summary TEXT,
    action TEXT,
    requires_reply TEXT,
    draft_reply TEXT,
    draft_id TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    links TEXT,
    phone_numbers TEXT,
    attachments TEXT
);

CREATE INDEX IF NOT EXISTS idx_email_assistant_created_at
    ON email_assistant (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_email_assistant_status
    ON email_assistant (status);

CREATE INDEX IF NOT EXISTS idx_email_assistant_requires_reply
    ON email_assistant (requires_reply);


CREATE TABLE IF NOT EXISTS whatsapp_sessions (
    id BIGSERIAL PRIMARY KEY,
    whatsapp_user TEXT NOT NULL UNIQUE,
    current_message_id TEXT,
    state TEXT NOT NULL DEFAULT 'idle',
    last_action TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_sessions_state
    ON whatsapp_sessions (state);

CREATE INDEX IF NOT EXISTS idx_whatsapp_sessions_current_message
    ON whatsapp_sessions (current_message_id);
