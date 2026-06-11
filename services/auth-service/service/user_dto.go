package service

type UserResponse struct {
	UserID      string `json:"userId"`
	DisplayName string `json:"displayName"`
	CreatedAt   string `json:"createdAt"`
	UpdatedAt   string `json:"updatedAt"`
}

type ListUsersResponse struct {
	Users []UserResponse `json:"users"`
}

type CreateUserRequest struct {
	DisplayName string `json:"displayName"`
}
