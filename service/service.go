package service

import "halo-suster/repo"

type Service interface{}

type svc struct {
	repo repo.Repo
}

func NewService(r repo.Repo) Service {
	return &svc{
		repo: r,
	}
}
