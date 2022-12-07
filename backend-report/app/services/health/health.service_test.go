package health

import (
	"context"
	"testing"
)

func TestAdd(t *testing.T) {
	service := New()
	got := service.Get(context.TODO())
	want := "Ok"

	if got != want {
		t.Errorf("got %q, wanted %q", got, want)
	}
}
