package audit

import "errors"

var ErrInvalidAuditServiceURL = errors.New("invalid audit service url")
var ErrAuditServiceRejectedEvent = errors.New("audit service rejected event")
