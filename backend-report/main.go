package main

import (
	"context"
	"log"
	"net/http"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/go-co-op/gocron"
	"github.com/gorilla/mux"
	httpSwagger "github.com/swaggo/http-swagger"

	reportRepository "backend-report/app/repositories/report"
	"backend-report/app/services/report"
	"backend-report/config"
	_ "backend-report/docs"
	"backend-report/routes"
	"backend-report/utility"
)

// @title Application API
// @version 1.0
// @description Auth apis (signup/login) and health apis
// @contact.name API Support
// @contact.email ypankaj007@gmail.com
// @license.name Apache 2.0
// @host localhost:8080
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
// @BasePath /api/v1
func main() {
	// Catch stop signals
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT,
	)
	defer stop()

	// Initialize config
	conf := config.NewConfig()

	// Router
	router := mux.NewRouter()
	routes.InitializeRoutes(router)

	// Swagger
	router.PathPrefix("/swagger").Handler(httpSwagger.WrapHandler)

	// Server configuration
	srv := &http.Server{
		Handler:      utility.Headers(router), // Set header to routes
		Addr:         ":" + conf.Port,
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	// Create wait group to collect all the goroutines
	wg := sync.WaitGroup{}

	connectCtx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	repository, err := reportRepository.New(connectCtx, conf.DataBaseConnectionURL)
	if err != nil {
		log.Fatalf("Error occurred during MongoDB connect: %q", err)
	}
	log.Printf("Successfully connected to MongoDB")

	wg.Add(1)
	go func() {
		defer wg.Done()
		<-ctx.Done()

		closeCtx, cancel := context.WithTimeout(ctx, 15*time.Second)
		defer cancel()

		if err := repository.Close(closeCtx); err != nil {
			log.Printf("Failed to close connection to MongoDB: %q", err)
		} else {
			log.Println("Successfully closed connection to MongoDB")
		}
	}()

	reporter := report.NewReporter(repository)

	scheduler := gocron.NewScheduler(time.UTC)
	_, err = scheduler.Every("5m").Do(func() {
		ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
		defer cancel()

		err := reporter.SaveReport(ctx, "https://d5dg7f2abrq3u84p3vpr.apigw.yandexcloud.net/report")
		if err != nil {
			log.Printf("Report error: %q", err)
		}
	})
	if err != nil {
		log.Fatalf("Report scheduler initialization error: %q", err)
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		scheduler.StartBlocking()
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		<-ctx.Done()

		scheduler.Stop()
	}()

	// Serving application at specified port
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			log.Printf("Failed to stop http listener: %q", err)
		}
	}()
	log.Println("Application is running at", conf.Port)

	wg.Add(1)
	go func() {
		defer wg.Done()
		<-ctx.Done()

		shutCtx, cancel := context.WithTimeout(ctx, 15*time.Second)
		defer cancel()

		if err := srv.Shutdown(shutCtx); err != nil {
			log.Printf("Failed to stop reporting server: %q", err)
		} else {
			log.Println("Successfully stopped reporting server")
		}
	}()

	wg.Wait()
}
