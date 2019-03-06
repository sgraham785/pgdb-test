package main

import (
	"fmt"
	"os"

	"github.com/go-kit/kit/log"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	// Create a single logger, which we'll use and give to other components.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.With(logger, "ts", log.DefaultTimestampUTC)
		logger = log.With(logger, "caller", log.DefaultCaller)
	}

	var dburl = "postgres://user:password@pgdb/db_name?search_path=public"

	db, err := sqlx.Open("postgres", dburl)
	if err != nil {
		logger.Log("app", "pgdb-test", "msg", "Database unreachable", "err", err)
	}

	var result string
	err = db.QueryRowx("SELECT * FROM test").StructScan(&result)
	if err != nil {
		logger.Log("app", "pgdb-test", "msg", "Select error", "err", err)
	}
	logger.Log("success", "true")
	fmt.Printf("result: %v\n", &result)
}
