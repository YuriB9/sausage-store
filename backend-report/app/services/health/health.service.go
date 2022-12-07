package health

import (
	"backend-report/config"
	"context"
)

type HealthServiceInterface interface {
	Get(context.Context) string
}

// HealthService , implements HealthService
// and perform health related business logics
type HealthService struct {
	config *config.Configuration
}

var (
	Answer = "Ok"
)

// New function will initialize HealthService
func New() HealthServiceInterface {
	return &HealthService{}
}

// Get function will find health by id
// return health and error if any
func (service *HealthService) Get(ctx context.Context) string {
	return Answer
}
