package routes

import (
	api "backend-report/app/handlers"
	userSrv "backend-report/app/services/health"
	"net/http"

	"github.com/gorilla/mux"
)

var (
	BaseRoute = "/api/v1"
)

func InitializeRoutes(router *mux.Router) {
	userService := userSrv.New()
	userAPI := api.NewHealthApi(userService)

	// Routes
	// -------------------------- Health API ------------------------------------
	router.HandleFunc(BaseRoute+"/health", userAPI.Get).Methods(http.MethodGet)
}
