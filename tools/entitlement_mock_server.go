package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"
	"time"
)

type EntitlementRecord struct {
	Entitlement       string `json:"entitlement"`
	Status            string `json:"status"`
	ExpiresAt         *int64 `json:"expiresAt"`
	LastVerifiedAt    int64  `json:"lastVerifiedAt"`
	VerificationToken string `json:"verificationToken"`
	Source            string `json:"source"`
}

type SyncRequest struct {
	AppUserID string `json:"appUserId"`
	Platform  string `json:"platform"`
}

type DebugSetRequest struct {
	AppUserID         string `json:"appUserId"`
	Entitlement       string `json:"entitlement"`
	Status            string `json:"status"`
	ExpiresAt         *int64 `json:"expiresAt"`
	VerificationToken string `json:"verificationToken"`
}

type DebugResetRequest struct {
	AppUserID string `json:"appUserId"`
}

var (
	records = map[string]EntitlementRecord{}
	mu      sync.RWMutex
)

func nowUnix() int64 {
	return time.Now().UTC().Unix()
}

func defaultRecord() EntitlementRecord {
	return EntitlementRecord{
		Entitlement:       "free",
		Status:            "unknown",
		ExpiresAt:         nil,
		LastVerifiedAt:    nowUnix(),
		VerificationToken: "",
		Source:            "server",
	}
}

func ensureRecord(appUserID string) EntitlementRecord {
	mu.RLock()
	record, ok := records[appUserID]
	mu.RUnlock()
	if ok {
		return record
	}

	record = defaultRecord()
	mu.Lock()
	records[appUserID] = record
	mu.Unlock()
	return record
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("failed to encode response: %v", err)
	}
}

func decodeJSON(r *http.Request, target any) error {
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(target)
}

func syncEntitlementHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req SyncRequest
	if err := decodeJSON(r, &req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
		return
	}

	if req.AppUserID == "" {
		req.AppUserID = "anonymous-local"
	}

	record := ensureRecord(req.AppUserID)
	writeJSON(w, http.StatusOK, record)
}

func getEntitlementHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	appUserID := r.URL.Query().Get("appUserId")
	if appUserID == "" {
		appUserID = "anonymous-local"
	}

	record := ensureRecord(appUserID)
	writeJSON(w, http.StatusOK, record)
}

func debugSetHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req DebugSetRequest
	if err := decodeJSON(r, &req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
		return
	}

	if req.AppUserID == "" {
		req.AppUserID = "anonymous-local"
	}
	if req.Entitlement == "" {
		req.Entitlement = "free"
	}
	if req.Status == "" {
		req.Status = "unknown"
	}

	token := req.VerificationToken
	if token == "" && req.Entitlement == "premium" {
		token = fmt.Sprintf("debug-token-%d", nowUnix())
	}

	record := EntitlementRecord{
		Entitlement:       req.Entitlement,
		Status:            req.Status,
		ExpiresAt:         req.ExpiresAt,
		LastVerifiedAt:    nowUnix(),
		VerificationToken: token,
		Source:            "server",
	}

	mu.Lock()
	records[req.AppUserID] = record
	mu.Unlock()

	writeJSON(w, http.StatusOK, map[string]any{
		"ok":        true,
		"appUserId": req.AppUserID,
		"record":    record,
	})
}

func debugResetHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req DebugResetRequest
	_ = decodeJSON(r, &req)

	mu.Lock()
	if req.AppUserID != "" {
		delete(records, req.AppUserID)
	} else {
		records = map[string]EntitlementRecord{}
	}
	mu.Unlock()

	writeJSON(w, http.StatusOK, map[string]any{
		"ok":        true,
		"appUserId": req.AppUserID,
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if _, err := strconv.Atoi(port); err != nil {
		log.Fatalf("invalid PORT value: %q", port)
	}

	http.HandleFunc("/entitlements/sync", syncEntitlementHandler)
	http.HandleFunc("/entitlements/me", getEntitlementHandler)
	http.HandleFunc("/debug/set", debugSetHandler)
	http.HandleFunc("/debug/reset", debugResetHandler)

	addr := ":" + port
	log.Printf("entitlement mock server running at http://localhost%s", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
