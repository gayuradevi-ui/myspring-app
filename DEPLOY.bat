@echo off
REM ============================================================================
REM TransactionData Wallet App - Complete Deploy Script
REM ============================================================================
REM This script performs all 3 steps: Build, Docker, and Cloud Run deployment
REM Run this from: C:\Users\GDEVI6\Downloads\TransactionData\datajpa\datajpa\demo
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════════════╗
echo ║         WALLET APP - COMPLETE DEPLOYMENT SCRIPT                       ║
echo ║              All 3 Steps Will Execute Automatically                    ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo.

REM Verify we're in the right directory
if not exist "pom.xml" (
    echo ERROR: pom.xml not found!
    echo Please run this script from: C:\Users\GDEVI6\Downloads\TransactionData\datajpa\datajpa\demo
    pause
    exit /b 1
)

REM ============================================================================
REM STEP 1: BUILD THE APPLICATION
REM ============================================================================

echo.
echo ════════════════════════════════════════════════════════════════════════
echo STEP 1 OF 3: BUILDING SPRING BOOT APPLICATION
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Running: mvn clean install -DskipTests
echo.

call mvnw.cmd clean install -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ BUILD FAILED! Maven returned error code %ERRORLEVEL%
    echo.
    echo Possible solutions:
    echo   1. Ensure Java 17+ is installed: java -version
    echo   2. Ensure Maven is available: mvn -version
    echo   3. Check internet connection for downloading dependencies
    echo   4. Run: mvnw.cmd clean to clear and retry
    echo.
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                    ✅ BUILD SUCCESSFUL!                              ║
echo ║              JAR file created: target/demo-0.0.1-SNAPSHOT.jar         ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

REM ============================================================================
REM STEP 2: BUILD & PUSH DOCKER IMAGE
REM ============================================================================

echo.
echo ════════════════════════════════════════════════════════════════════════
echo STEP 2 OF 3: BUILDING & PUSHING DOCKER IMAGE
echo ════════════════════════════════════════════════════════════════════════
echo.

echo Building Docker image: gayathri-wallet-app:latest
call docker build -t gayathri-wallet-app:latest .

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ DOCKER BUILD FAILED!
    echo.
    echo Possible solutions:
    echo   1. Ensure Docker is installed and running
    echo   2. Run: docker --version
    echo   3. Start Docker Desktop if on Windows/Mac
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Docker image built successfully
echo.

echo Tagging image for Google Container Registry...
call docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ DOCKER TAG FAILED!
    pause
    exit /b 1
)

echo ✅ Image tagged successfully
echo.

echo Pushing image to GCR...
call docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ DOCKER PUSH FAILED!
    echo.
    echo Possible solutions:
    echo   1. Ensure you're authenticated: gcloud auth configure-docker
    echo   2. Ensure you have permission to push to: gcr.io/cybernetic-pact-417810
    echo   3. Check internet connection
    echo.
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║              ✅ DOCKER IMAGE PUSHED SUCCESSFULLY!                    ║
echo ║  Image: gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest      ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

REM ============================================================================
REM STEP 3: DEPLOY TO CLOUD RUN
REM ============================================================================

echo.
echo ════════════════════════════════════════════════════════════════════════
echo STEP 3 OF 3: DEPLOYING TO GOOGLE CLOUD RUN
echo ════════════════════════════════════════════════════════════════════════
echo.

echo Deploying service: gayathriwalletdb-dev
call gcloud run deploy gayathriwalletdb-dev ^
  --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest ^
  --region asia-south1 ^
  --platform managed ^
  --allow-unauthenticated ^
  --set-env-vars "SPRING_PROFILES_ACTIVE=dev"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ CLOUD RUN DEPLOYMENT FAILED!
    echo.
    echo Possible solutions:
    echo   1. Ensure gcloud CLI is installed
    echo   2. Authenticate: gcloud auth login
    echo   3. Set project: gcloud config set project cybernetic-pact-417810
    echo   4. Check permissions in your GCP project
    echo.
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                 ✅ ALL STEPS COMPLETED SUCCESSFULLY!                 ║
echo ║              Your wallet app is now LIVE on Cloud Run! 🎉            ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

echo.
echo 📊 DEPLOYMENT SUMMARY
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✅ Maven Build:        Successfully completed
echo ✅ Docker Image:       Built and pushed to GCR
echo ✅ Cloud Run Service:  Deployed to asia-south1
echo.
echo 🌐 SERVICE URL:
echo    https://gayathriwalletdb-dev-336975820039.asia-south1.run.app
echo.
echo 📮 ENDPOINT FOR TESTING:
echo    POST https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register
echo.
echo 🧪 NEXT STEP - TEST IN POSTMAN
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Method:  POST
echo URL:     https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register
echo Headers: Content-Type: application/json
echo.
echo Body:
echo {
echo   "name": "Gayathri",
echo   "phoneNumber": 456789,
echo   "email": "gayu@email.com",
echo   "password": "3456jsht",
echo   "balance": 0.1,
echo   "city": "Chennai"
echo }
echo.
echo Expected Response Status: 201 Created
echo.
echo 📝 TROUBLESHOOTING
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo View deployment logs:
echo   gcloud run logs read gayathriwalletdb-dev --region asia-south1 --limit 50
echo.
echo Verify Cloud SQL:
echo   gcloud sql instances list
echo   gcloud sql databases list --instance=gayathri-postgres
echo.

pause

