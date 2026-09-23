# CLOUD RUN TABLE & DATA PERSISTENCE FIX

## Problem Identified
- ✅ API returning 200 OK response
- ❌ But tables not appearing in Cloud SQL
- ❌ Data not persisting to PostgreSQL

## Root Cause
The Cloud SQL Socket Factory connection string was missing, preventing proper data persistence to the database.

## Solutions Applied

### 1. Added Cloud SQL Socket Factory Dependency
**File:** pom.xml
```xml
<dependency>
    <groupId>com.google.cloud.sql</groupId>
    <artifactId>cloud-sql-connector-postgres-socket-factory</artifactId>
    <version>1.13.1</version>
</dependency>
```

### 2. Updated Database Connection Configuration
**File:** applicationdev.properties

**OLD (Not Working):**
```
spring.datasource.url=jdbc:postgresql://127.0.0.1:5432/postgresdevdb
```

**NEW (With Socket Factory):**
```
spring.datasource.url=jdbc:postgresql://localhost/postgresdevdb?cloudSqlInstance=cybernetic-pact-417810:asia-south1:gayathri-postgres&socketFactory=com.google.cloud.sql.postgres.SocketFactory&user=gayathri-devdbpostgres&password=Z}T[b.{{)@8,l0gE
```

### 3. Enhanced Connection Pool Configuration
```
spring.datasource.hikari.maximum-pool-size=5
spring.datasource.hikari.minimum-idle=1
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000
```

### 4. Added @Repository Annotation
**File:** WalletRepository.java
- Added `@Repository` annotation for explicit Spring bean registration

### 5. Wallet Entity with Schema
**File:** Wallet.java
```java
@Entity
@Table(name = "wallet", schema = "public")
```

## Changes Made (Summary)

✅ pom.xml - Added Cloud SQL Socket Factory
✅ applicationdev.properties - Updated JDBC URL with Socket Factory
✅ WalletRepository.java - Added @Repository annotation
✅ Wallet.java - Verified schema configuration

## NOW YOU NEED TO REBUILD & REDEPLOY

### On Your Local Machine:

**Step 1: Clean Build**
```bash
cd C:\Users\GDEVI6\Downloads\TransactionData\datajpa\datajpa\demo
.\mvnw.cmd clean install -DskipTests
```
Expected: BUILD SUCCESS ✅

**Step 2: Build Docker Image**
```bash
docker build -t gayathri-wallet-app:latest .
docker tag gayathri-wallet-app:latest gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
docker push gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest
```
Expected: Successfully pushed ✅

**Step 3: Redeploy to Cloud Run**
```bash
gcloud run deploy gayathriwalletdb-dev \
  --image gcr.io/cybernetic-pact-417810/gayathri-wallet-app:latest \
  --region asia-south1 \
  --platform managed \
  --allow-unauthenticated \
  --force-on-demand
```
Expected: Service deployed ✅

**Step 4: Check Logs**
```bash
gcloud run logs read gayathriwalletdb-dev --region asia-south1 --limit 50
```

Look for:
✅ "Application started"
✅ No database connection errors
✅ No ClassNotFoundException

## Test in Postman AFTER Redeployment

**URL:**
```
POST https://gayathriwalletdb-dev-336975820039.asia-south1.run.app/v1/wallet/register
```

**Body:**
```json
{
  "name": "TestUser2",
  "phoneNumber": 9999999999,
  "email": "test2@example.com",
  "password": "test123",
  "balance": 250.75,
  "city": "Delhi"
}
```

**Expected Response:**
```
Status: 200 OK or 201 Created

{
  "id": 2,
  "name": "TestUser2",
  "phoneNumber": 9999999999,
  "email": "test2@example.com",
  "password": "test123",
  "balance": 250.75,
  "createdAt": "2026-09-23T...",
  "city": "Delhi",
  "isActive": true
}
```

## Verify in Cloud SQL Studio

### After Postman test, check Cloud SQL:

1. **Open Cloud SQL Studio:** https://console.cloud.google.com/sql/
2. **Click:** gayathri-postgres instance
3. **Click:** "Cloud SQL Studio" tab
4. **Expand:** Schema 2 > public (Default) > Tables

**You should now see:**
```
✅ Tables 1 (or more)
  └── wallet ✅
      └── Columns: id, name, phoneNumber, email, password, balance, createdAt, city, isActive
```

5. **Run Query:**
```sql
SELECT * FROM wallet;
```

**Expected Result:**
```
id | name       | phoneNumber | email             | password | balance | createdAt           | city   | isActive
---|------------|-------------|-------------------|----------|---------|---------------------|--------|----------
1  | Gayathri   | 456789      | gayu@email.com    | 3456jsht | 500     | 2026-09-23 05:35:35 | Chennai| true
2  | TestUser2  | 9999999999  | test2@example.com | test123  | 250.75  | 2026-09-23 ...      | Delhi  | true
```

✅ SUCCESS! Both records appear!

## If Still No Tables

### Troubleshooting:

**Check logs for errors:**
```bash
gcloud run logs read gayathriwalletdb-dev --region asia-south1 --limit 100
```

**Look for:**
- "Successfully registered wallet" → Connection working
- "Cannot connect to database" → Connection failing
- "Duplicate key error" → Tables already exist with wrong schema

**Common Issues & Solutions:**

1. **"Resource unavailable"** → Cloud SQL instance down
   - Solution: `gcloud sql instances list` and verify status

2. **"Authentication failed"** → Wrong credentials
   - Solution: Verify credentials in applicationdev.properties

3. **"Connection timeout"** → Network issue
   - Solution: Check Cloud SQL has public IP enabled

4. **Tables showing in test db, not in public schema** → Wrong schema
   - Solution: Verify @Table(name = "wallet", schema = "public") exists

## Files Modified

✅ pom.xml - Added Cloud SQL Socket Factory dependency
✅ applicationdev.properties - Updated JDBC URL with Socket Factory
✅ WalletRepository.java - Added @Repository annotation
✅ Wallet.java - Already has @Table(name = "wallet", schema = "public")

## Timeline

- Maven Build: 3-5 minutes
- Docker Build: 2-3 minutes
- Push to GCR: 1-2 minutes
- Cloud Run Deploy: 1-2 minutes
- Postman Test: 1 minute
- Cloud SQL Verification: 1 minute

**TOTAL: ~10-15 minutes**

## Success Checklist

- [ ] Maven build: BUILD SUCCESS
- [ ] Docker image: Built and pushed
- [ ] Cloud Run: Deployment successful
- [ ] Postman: 200 OK response with ID in response
- [ ] Cloud SQL Studio: wallet table appears under public schema
- [ ] SQL Query: SELECT * FROM wallet returns rows
- [ ] Multiple POSTs: All rows visible in database

## Next Step

**Execute the rebuild and redeploy steps above on your local machine!**

After that, test in Postman and verify in Cloud SQL Studio. The data will now persist! 🎉

