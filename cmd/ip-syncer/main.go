package main

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"regexp"

	"github.com/cloudflare/cloudflare-go"
)

func main() {
	// Get ENV values
	APIKey := os.Getenv("API_KEY")
	if APIKey == "" {
		log.Fatal(errors.New("invalid API_KEY env value"))
	}
	cfEmail := os.Getenv("API_EMAIL")
	if cfEmail == "" {
		log.Fatal(errors.New("invalid API_EMAIL env value"))
	}
	domain := os.Getenv("DOMAIN")
	if domain == "" {
		log.Fatal(errors.New("invalid DOMAIN env value"))
	}
	record := os.Getenv("RECORD")
	if record == "" {
		log.Fatal(errors.New("invalid RECORD env value"))
	}

	// initialize cloudflare with respective values
	api, err := cloudflare.New(APIKey, cfEmail)
	if err != nil {
		log.Fatal(err)
	}

	// fetch the zone ID
	zoneID, err := api.ZoneIDByName(domain)
	if err != nil {
		log.Fatal(err)
	}

	// fetch dns records
	records, err := api.DNSRecords(zoneID, cloudflare.DNSRecord{})
	if err != nil {
		log.Fatal(err)
	}

	// define subDomain
	subDomain := fmt.Sprintf("%s.%s", record, domain)

	// get record id
	var recordID string
	for _, r := range records {
		if r.Name == subDomain {
			recordID = r.ID
		}
	}

	// check if recordID curl ifconfig.cois defined
	if recordID == "" {
		log.Fatal(errors.New("the subdomain is not found or it's not was created  yet in Cloudflare"))
	}

	// define command to get the public ip and their outpurt
	cmd := exec.Command("dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")
	var out bytes.Buffer
	cmd.Stdout = &out

	// run command
	err = cmd.Run()
	if err != nil {
		log.Fatal(err)
	}

	// regext to extract only ip value
	re := regexp.MustCompile(`(\d)+.(\d)+.(\d)+.(\d)+`)
	ip := re.FindString(out.String())

	// update subdomain dsn record
	err = api.UpdateDNSRecord(zoneID, recordID, cloudflare.DNSRecord{
		Content: ip,
		Proxied: true,
	})
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("successful change the IP to %s", ip)
}
