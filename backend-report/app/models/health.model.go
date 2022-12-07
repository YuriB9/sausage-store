package models

// Report , definds health model
type Report struct {
	ProductId    int32  `bson:"productId"`
	Name         string `bson:"name"`
	Quantity     int32  `bson:"quantity"`
	Length       int32  `bson:"length"`
	Class        string `bson:"class"`
	PEPE         string `bson:"pepe"`
	WasDelicious bool   `bson:"wasdelicious"`
}
