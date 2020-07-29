package main

import (
	"context"
	"log"
	"os"
	"github.com/go-redis/redis/v8"
	"math/rand"
	"time"
	"strings"
)

const charset = "abcdefghijklmnopqrstuvwxyz" +
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))

func main() {
	var (
		hosts = getEnv("REDIS_HOSTS", "localhost:6379,localhost:6380")
	)

	addrs := strings.Split(hosts, ",")

	client := redis.NewClusterClient(&redis.ClusterOptions{
		Addrs: addrs,
	})

	var ctx = context.Background()

	_, err := client.Ping(ctx).Result()
	if err != nil {
		log.Fatal(err)
	}

	for i := 0; i < 10000; i++ {
		err := client.Set(ctx, createRandString(50), createRandString(200), 0).Err()
		if err != nil {
			log.Fatal("Cannot set data", err)
		}
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

func createRandString(length int) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}
