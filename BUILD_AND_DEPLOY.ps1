# Build and Deploy Script for TransactionData Wallet App

Write-Host "`n================================================`n" -ForegroundColor Cyan
Write-Host "Step 1: Building the Spring Boot Application" -ForegroundColor Cyan
Write-Host "`n================================================`n" -ForegroundColor Cyan

# Build the Maven project
& ".\mvnw.cmd" clean install -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Maven build failed!`n" -ForegroundColor Red
    exit 1
}

Write-Host "`n================================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "JAR file created: target/demo-0.0.1-SNAPSHOT.jar" -ForegroundColor Green
Write-Host "`n================================================`n" -ForegroundColor Green

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Step 2: Testing Locally (Optional)" -ForegroundColor Cyan
Write-Host "`n================================================`n" -ForegroundColor Cyan

Write-Host "To test locally before deploying to Cloud Run:" -ForegroundColor Yellow
Write-Host "  java -jar target/demo-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev`n"

Write-Host "The app will be available at: http://localhost:8080" -ForegroundColor Yellow
Write-Host "Test the endpoint: POST http://localhost:8080/v1/wallet/register`n"

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Step 3: Deploy to Cloud Run" -ForegroundColor Cyan
Write-Host "`n================================================`n" -ForegroundColor Cyan

Write-Host "Run the following commands:`n" -ForegroundColor Yellow

Write-Host "1. Build and push Docker image:" -ForegroundColor Yellow
Write-Host "   docker build -t gayathri-wallet-app:latest ."
Write-Host "   docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest"
Write-Host "   docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest`n"

Write-Host "2. Deploy to Cloud Run:" -ForegroundColor Yellow
Write-Host "   gcloud run deploy gayathriwalletdb-dev --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest --region asia-south1 --platform managed --allow-unauthenticated`n"

Write-Host "3. Verify deployment:" -ForegroundColor Yellow
Write-Host "   gcloud run services describe gayathriwalletdb-dev --region asia-south1`n"

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Step 4: Test the Deployed Endpoint" -ForegroundColor Cyan
Write-Host "`n================================================`n" -ForegroundColor Cyan

Write-Host "Use the following URL in Postman:" -ForegroundColor Yellow
Write-Host "  POST http://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register`n"

Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host @"
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
"@

Write-Host "`nExpected Response: 201 Created (or 200 OK)" -ForegroundColor Green
Write-Host "`nData will be automatically saved to PostgreSQL Cloud SQL database!" -ForegroundColor Green

