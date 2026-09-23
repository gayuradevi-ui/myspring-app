# Deployment Guide - TransactionData Wallet App

## Overview
This guide walks you through building and deploying your Spring Boot wallet application to Google Cloud Run with PostgreSQL Cloud SQL.

---

## Prerequisites
- Java 17+ installed
- Maven 3.9+ (or use included mvnw wrapper)
- Docker installed and configured
- Google Cloud SDK (gcloud) installed
- GCP project credentials configured

---

## Step 1: Build the Application Locally

### Option A: Using Maven Wrapper (Recommended)
```bash
cd C:\Users\GDEVI6\Downloads\TransactionData\datajpa\datajpa\demo

# Build the project
.\mvnw.cmd clean install -DskipTests
```

### Option B: Using PowerShell Script
```powershell
# Run the build script
.\BUILD_AND_DEPLOY.ps1
```

**Expected Output:**
- Successfully compiled classes
- Created: `target/demo-0.0.1-SNAPSHOT.jar` (approximately 50-100 MB)
- No compilation errors

---

## Step 2: Verify the Changes (Optional - Test Locally)

### Run the application locally:
```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

### Test the endpoint:
```bash
# In Postman or curl:
POST http://localhost:8080/v1/wallet/register

Body:
{
  "name": "Gayathri",
  "phoneNumber": 456789,
  "email": "gayu@email.com",
  "password": "3456jsht",
  "balance": 0.1,
  "city": "Chennai"
}

# Expected Response: 201 Created
```

---

## Step 3: Build and Push Docker Image

### 1. Build the Docker image:
```bash
cd C:\Users\GDEVI6\Downloads\TransactionData\datajpa\datajpa\demo
docker build -t gayathri-wallet-app:latest .
```

### 2. Tag the image for Google Container Registry:
```bash
docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
```

### 3. Push to Google Container Registry:
```bash
docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
```

**Expected Output:**
```
Pushed to gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
Image successfully pushed!
```

---

## Step 4: Deploy to Cloud Run

### Deploy with environment-specific configuration:
```bash
gcloud run deploy gayathriwalletdb-dev \
  --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest \
  --region asia-south1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars "SPRING_PROFILES_ACTIVE=dev"
```

**Expected Output:**
```
Service [gayathriwalletdb-dev] revision [gayathriwalletdb-dev-xxxxx] has been deployed and is serving 100 percent of traffic.
Service URL: https://gayathriwalletdb-dev-336975820039.asia-south1.run.app
```

### Verify the deployment:
```bash
gcloud run services describe gayathriwalletdb-dev --region asia-south1
```

---

## Step 5: Test the Deployed Endpoint

### In Postman:
1. **Method:** POST
2. **URL:** `https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register`
3. **Headers:** `Content-Type: application/json`
4. **Body:**
```json
{
  "id": 1,
  "name": "Gayathri",
  "phoneNumber": 456789,
  "email": "gayu@email.com",
  "password": "3456jsht",
  "balance": 0.1,
  "createdAt": "2026-09-23T05:35:35.968Z",
  "city": "Chennai"
}
```

### Expected Response:
```
Status: 201 Created

{
  "id": 1,
  "name": "Gayathri",
  "phoneNumber": 456789,
  "email": "gayu@email.com",
  "password": "3456jsht",
  "balance": 0.1,
  "createdAt": "2026-09-23T05:35:35.968Z",
  "city": "Chennai"
}
```

### Verify in PostgreSQL:
```sql
-- Connect to your PostgreSQL database
SELECT * FROM wallet;

-- You should see your newly registered wallet
```

---

## What Was Fixed

### 1. ✅ WalletController - Missing Return Types
**File:** `src/main/java/com/datajpa/demo/wallet/WalletController.java`
- Added `public` keyword to method signatures
- Added `@ResponseStatus(HttpStatus.CREATED)` to return proper HTTP status
- Added proper imports for HttpStatus

### 2. ✅ Missing Dependencies
**File:** `pom.xml`
- Added: `spring-cloud-gcp-starter-sql-postgresql` (for Cloud SQL support)
- Added: `postgresql` JDBC driver (for database connectivity)
- Changed: `spring-boot-starter-webmvc` → `spring-boot-starter-web`

### 3. ✅ Database Configuration
**File:** `src/main/resources/applicationdev.properties`
- Changed dialect: `H2Dialect` → `PostgreSQLDialect`
- Added JDBC URL: `jdbc:postgresql://localhost/postgresdevdb`
- Fixed spacing in configuration properties
- Used proper driver: `org.postgresql.Driver`

### 4. ✅ Correct Endpoint
- Changed from `/v1/wallet/regist` → `/v1/wallet/register`

---

## Troubleshooting

### Issue: 302 Found Response
**Solution:** Ensure you're using the correct endpoint: `/v1/wallet/register` (not `/regist`)

### Issue: Cannot connect to database
**Solution:** Verify Cloud SQL is enabled and credentials are correct:
```bash
gcloud sql instances list
gcloud sql databases list --instance=gayathri-postgres
```

### Issue: Maven build fails
**Solution:** Ensure Java 17 is installed:
```bash
java -version
```

### Issue: Docker image push fails
**Solution:** Authenticate with GCP:
```bash
gcloud auth configure-docker
```

### Issue: Cloud Run deployment fails
**Solution:** Check deployment logs:
```bash
gcloud run logs read gayathriwalletdb-dev --region asia-south1 --limit 50
```

---

## Quick Commands Summary

```bash
# 1. Build
.\mvnw.cmd clean install -DskipTests

# 2. Build Docker image
docker build -t gayathri-wallet-app:latest .

# 3. Push to registry
docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest

# 4. Deploy to Cloud Run
gcloud run deploy gayathriwalletdb-dev --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest --region asia-south1 --platform managed --allow-unauthenticated

# 5. Test endpoint
curl -X POST https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Gayathri","phoneNumber":456789,"email":"gayu@email.com","password":"3456jsht","balance":0.1,"city":"Chennai"}'
```

---

## Success Indicators ✅

- ✅ Maven build completes without errors
- ✅ Docker image builds successfully
- ✅ Image pushed to GCR
- ✅ Cloud Run deployment succeeds
- ✅ POST /v1/wallet/register returns **201 Created**
- ✅ Response contains the saved wallet object with ID
- ✅ Data persists in PostgreSQL Cloud SQL

**You should now be getting 200/201 responses and data will be saved to PostgreSQL!**

