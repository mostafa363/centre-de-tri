# MongoDB Setup for Digit Recognition

## Option 1: Local MongoDB (Recommended for Development)

1. **Download MongoDB Community Server:**
   - Visit: https://www.mongodb.com/try/download/community
   - Download for Windows
   - Install with default settings

2. **Start MongoDB:**
   ```powershell
   # MongoDB should auto-start as a service
   # Or manually start:
   net start MongoDB
   ```

3. **Verify MongoDB is running:**
   ```powershell
   mongosh
   # You should see MongoDB shell
   ```

## Option 2: MongoDB Atlas (Free Cloud Database)

1. **Create Account:**
   - Go to: https://www.mongodb.com/cloud/atlas/register
   - Sign up for free

2. **Create Cluster:**
   - Choose FREE tier (M0)
   - Select region closest to you
   - Click "Create Cluster"

3. **Get Connection String:**
   - Click "Connect" on your cluster
   - Choose "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your password

4. **Update API:**
   Set environment variable before starting API:
   ```powershell
   $env:MONGO_URI="mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/digit_recognition?retryWrites=true&w=majority"
   Rscript api/run_api.R
   ```

## Testing MongoDB Connection

Once MongoDB is running, restart the API:
```powershell
Rscript api/run_api.R
```

You should see: `✅ MongoDB connected`

## API Endpoints

- `POST /predict` - Predict digit (auto-saves to MongoDB)
- `GET /predictions/history?limit=50` - Get recent predictions
- `GET /predictions/stats` - Get statistics
- `DELETE /predictions/clear` - Clear history

## Default Configuration

- **URI**: `mongodb://localhost:27017` (local)
- **Database**: `digit_recognition`
- **Collection**: `predictions`

The API will work WITHOUT MongoDB (predictions just won't be saved).
