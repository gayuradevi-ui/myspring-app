@echo off
REM Build and Deploy Script for TransactionData Wallet App

echo.
echo ================================================
echo Step 1: Building the Spring Boot Application
echo ================================================
echo.

REM Build the Maven project
call mvnw.cmd clean install -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Maven build failed!
    pause
    exit /b 1
)

echo.
echo ================================================
echo Build completed successfully!
echo JAR file created: target/demo-0.0.1-SNAPSHOT.jar
echo ================================================
echo.
echo.
echo ================================================
echo Step 2: Testing Locally (Optional)
echo ================================================
echo.
echo To test locally before deploying to Cloud Run:
echo   java -jar target/demo-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
echo.
echo The app will be available at: http://localhost:8080
echo Test the endpoint: POST http://localhost:8080/v1/wallet/register
echo.
echo.
echo ================================================
echo Step 3: Deploy to Cloud Run
echo ================================================
echo.
echo Run the following commands in PowerShell/CMD:
echo.
echo 1. Build and push Docker image:
echo    docker build -t gayathri-wallet-app:latest .
echo    docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
echo    docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
echo.
echo 2. Deploy to Cloud Run:
echo    gcloud run deploy gayathriwalletdb-dev --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest --region asia-south1 --platform managed
echo.
echo 3. Verify deployment:
echo    gcloud run services describe gayathriwalletdb-dev --region asia-south1
echo.
echo.
echo ================================================
echo Step 4: Test the Deployed Endpoint
echo ================================================
echo.
echo Use the following URL in Postman:
echo   POST http://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register
echo.
echo Request Body:
echo {
echo   "id": 1,
echo   "name": "Gayathri",
echo   "phoneNumber": 456789,
echo   "email": "gayu@email.com",
echo   "password": "3456jsht",
echo   "balance": 0.1,
echo   "createdAt": "2026-09-23T05:35:35.968Z",
echo   "city": "Chennai"
echo }
echo.
echo Expected Response: 201 Created (or 200 OK)
echo.
pause

