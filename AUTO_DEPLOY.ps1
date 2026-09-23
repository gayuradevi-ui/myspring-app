#!/usr/bin/env pwsh
# Complete automation script for building and deploying the Wallet App

Write-Host "
╔════════════════════════════════════════════════════════════════════════════╗
║                  WALLET APP - BUILD & DEPLOY AUTOMATION                   ║
║                   All 3 Steps Will Execute Automatically                   ║
╚════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

$projectPath = (Get-Location).Path
Write-Host "📂 Project Path: $projectPath" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# STEP 1: BUILD THE APPLICATION
# ============================================================================

Write-Host "
════════════════════════════════════════════════════════════════════════════
STEP 1 OF 3: BUILDING SPRING BOOT APPLICATION
════════════════════════════════════════════════════════════════════════════
" -ForegroundColor Green

Write-Host "🔨 Running: mvn clean install -DskipTests" -ForegroundColor Yellow
Write-Host ""

$buildStart = Get-Date
& ".\mvnw.cmd" clean install -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "
❌ BUILD FAILED! Maven returned error code $LASTEXITCODE
Please check the error messages above and fix any compilation issues.
" -ForegroundColor Red
    exit 1
}

$buildEnd = Get-Date
$buildTime = ($buildEnd - $buildStart).TotalSeconds
Write-Host "
✅ BUILD SUCCESSFUL! (Completed in $buildTime seconds)
📦 JAR File: $(Get-Item -Path 'target/demo-0.0.1-SNAPSHOT.jar' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
" -ForegroundColor Green

# ============================================================================
# STEP 2: BUILD DOCKER IMAGE & PUSH TO GCR
# ============================================================================

Write-Host "
════════════════════════════════════════════════════════════════════════════
STEP 2 OF 3: BUILDING & PUSHING DOCKER IMAGE
════════════════════════════════════════════════════════════════════════════
" -ForegroundColor Green

Write-Host "🐳 Building Docker image: gayathri-wallet-app:latest" -ForegroundColor Yellow
& docker build -t gayathri-wallet-app:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built successfully" -ForegroundColor Green

Write-Host ""
Write-Host "🏷️  Tagging image for GCR..." -ForegroundColor Yellow
& docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest

Write-Host "📤 Pushing image to Google Container Registry..." -ForegroundColor Yellow
& docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed!" -ForegroundColor Red
    Write-Host "Make sure you are authenticated: gcloud auth configure-docker" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Image pushed successfully to GCR" -ForegroundColor Green

# ============================================================================
# STEP 3: DEPLOY TO CLOUD RUN
# ============================================================================

Write-Host "
════════════════════════════════════════════════════════════════════════════
STEP 3 OF 3: DEPLOYING TO GOOGLE CLOUD RUN
════════════════════════════════════════════════════════════════════════════
" -ForegroundColor Green

Write-Host "🚀 Deploying to Cloud Run..." -ForegroundColor Yellow
$deployStart = Get-Date

& gcloud run deploy gayathriwalletdb-dev `
  --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest `
  --region asia-south1 `
  --platform managed `
  --allow-unauthenticated `
  --set-env-vars "SPRING_PROFILES_ACTIVE=dev"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cloud Run deployment failed!" -ForegroundColor Red
    Write-Host "Make sure you have gcloud CLI installed and authenticated" -ForegroundColor Yellow
    exit 1
}

$deployEnd = Get-Date
$deployTime = ($deployEnd - $deployStart).TotalSeconds
Write-Host "✅ Deployment successful! (Completed in $deployTime seconds)" -ForegroundColor Green

# ============================================================================
# DEPLOYMENT COMPLETE - NEXT STEPS
# ============================================================================

Write-Host "
╔════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT COMPLETED SUCCESSFULLY! ✅                   ║
╚════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "
📊 DEPLOYMENT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Maven Build:          Successfully completed
✅ Docker Image:         Built and pushed to GCR
✅ Cloud Run Service:    Deployed to asia-south1

🌐 SERVICE URL:
   https://gayathriwalletdb-dev-336975820039.asia-south1.run.app

📮 ENDPOINT:
   POST https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register

🧪 NEXT STEPS - TEST YOUR ENDPOINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Open Postman or your API testing tool

2️⃣  Create a new POST request with:
   URL: https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register
   Method: POST
   Header: Content-Type: application/json

3️⃣  Send this request body:
{
  ""name"": ""Gayathri"",
  ""phoneNumber"": 456789,
  ""email"": ""gayu@email.com"",
  ""password"": ""3456jsht"",
  ""balance"": 0.1,
  ""city"": ""Chennai""
}

4️⃣  Expected Response:
   Status: 201 Created
   Body: Your wallet object with auto-generated ID

5️⃣  Verify in PostgreSQL:
   SELECT * FROM wallet;

📋 TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Check deployment status:
  " -ForegroundColor Cyan

Write-Host "gcloud run services describe gayathriwalletdb-dev --region asia-south1" -ForegroundColor Yellow

Write-Host "
View deployment logs:
  " -ForegroundColor Cyan

Write-Host "gcloud run logs read gayathriwalletdb-dev --region asia-south1 --limit 50" -ForegroundColor Yellow

Write-Host "
✨ All done! Your wallet application is now live ✨
" -ForegroundColor Green

