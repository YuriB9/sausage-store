package handlers

import (
	userSrv "backend-report/app/services/health"
	"backend-report/utility"
	"net/http"
)

type HealthHandler struct {
	us userSrv.HealthServiceInterface
}

func NewHealthApi(userService userSrv.HealthServiceInterface) *HealthHandler {
	return &HealthHandler{
		us: userService,
	}
}

func (h *HealthHandler) Get(w http.ResponseWriter, r *http.Request) {
	health := h.us.Get(r.Context())

	utility.Response(w, utility.SuccessPayload(health, "I'm alive"))
}
