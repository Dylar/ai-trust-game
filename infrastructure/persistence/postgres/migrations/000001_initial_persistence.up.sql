CREATE TABLE users (
    id uuid PRIMARY KEY,
    display_name text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE sessions (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    role text NOT NULL,
    mode text NOT NULL,
    status text NOT NULL,
    state jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    completed_at timestamptz
);

CREATE INDEX sessions_user_id_updated_at_idx ON sessions (user_id, updated_at DESC);

CREATE TABLE interactions (
    id uuid PRIMARY KEY,
    session_id uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    request_id text NOT NULL,
    user_input text NOT NULL,
    selected_action text,
    policy_result jsonb NOT NULL DEFAULT '{}'::jsonb,
    response_text text NOT NULL DEFAULT '',
    pipeline jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL
);

CREATE INDEX interactions_session_id_created_at_idx ON interactions (session_id, created_at);
CREATE INDEX interactions_user_id_created_at_idx ON interactions (user_id, created_at DESC);
CREATE INDEX interactions_request_id_idx ON interactions (request_id);

CREATE TABLE audit_events (
    id uuid PRIMARY KEY,
    request_id text NOT NULL,
    session_id uuid,
    user_id uuid,
    event_type text NOT NULL,
    payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL
);

CREATE INDEX audit_events_request_id_created_at_idx ON audit_events (request_id, created_at);
CREATE INDEX audit_events_session_id_created_at_idx ON audit_events (session_id, created_at);
CREATE INDEX audit_events_user_id_created_at_idx ON audit_events (user_id, created_at DESC);
