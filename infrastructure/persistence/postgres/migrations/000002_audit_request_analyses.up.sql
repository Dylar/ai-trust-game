CREATE TABLE request_analyses (
    request_id text PRIMARY KEY,
    user_id uuid REFERENCES users (id) ON DELETE RESTRICT,
    session_id uuid REFERENCES sessions (id) ON DELETE CASCADE,
    started_at timestamptz NOT NULL,
    completed_at timestamptz NOT NULL,
    classification text NOT NULL,
    signals jsonb NOT NULL DEFAULT '[]'::jsonb,
    attack_patterns jsonb NOT NULL DEFAULT '[]'::jsonb,
    intent_summary text NOT NULL DEFAULT '',
    event_count integer NOT NULL,
    suspicion_count integer NOT NULL,
    model_fail_count integer NOT NULL
);

CREATE INDEX request_analyses_session_id_completed_at_idx ON request_analyses (session_id, completed_at);
CREATE INDEX request_analyses_user_id_completed_at_idx ON request_analyses (user_id, completed_at DESC);
