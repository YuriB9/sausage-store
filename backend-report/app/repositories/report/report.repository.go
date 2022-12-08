package report

import (
	"backend-report/app/models"
	"context"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

// Repository , used to perform DB oprations
// Inteface contains basic oprations on report document
// So that, db opration can be perform easily
type Repository interface {

	// Create, will perform db opration to save report
	// Returns modified report and error if occurs
	Create(context.Context, *models.Report) error

	// FildAll, returns all reports in the system
	// It will return error also if occurs
	FindAll(context.Context) ([]*models.Report, error)

	// Update, will update report data by id
	// return error if any
	Update(context.Context, interface{}, interface{}) error

	// Delete, will remove report entry from DB
	// Return error if any
	Delete(context.Context, *models.Report) error

	// FindOne, will find one entry of report matched by the query
	// Query object is an interface type that can accept any object
	// return matched report and error if any
	FindOne(context.Context, interface{}) (*models.Report, error)

	Close(ctx context.Context) error
}

type repositoryMongo struct {
	db *mongo.Client
}

func New(ctx context.Context, dbURI string) (Repository, error) {
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(dbURI))
	if err != nil {
		return nil, err
	}

	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		return nil, err
	}

	return &repositoryMongo{
		db: client,
	}, nil
}

func (service *repositoryMongo) Create(ctx context.Context, report *models.Report) error {
	_, err := service.collection().InsertOne(ctx, report)
	if err != nil {
		return err
	}

	return nil
}

func (service *repositoryMongo) FindAll(_ context.Context) ([]*models.Report, error) {
	return nil, nil
}

func (service *repositoryMongo) Update(ctx context.Context, query, change interface{}) error {
	_, err := service.collection().UpdateOne(ctx, query, change)
	if err != nil {
		return err
	}

	return nil
}

func (service *repositoryMongo) Delete(_ context.Context, _ *models.Report) error {
	return nil
}

func (service *repositoryMongo) FindOne(ctx context.Context, query interface{}) (*models.Report, error) {
	var report models.Report

	result := service.collection().FindOne(ctx, query)
	err := result.Decode(&report)

	return &report, err
}

func (service *repositoryMongo) collection() *mongo.Collection {
	return service.db.Database().Collection("reports")
}

func (service *repositoryMongo) Close(ctx context.Context) error {
	return service.db.Disconnect(ctx)
}
