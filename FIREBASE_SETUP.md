# Firebase Integration Guide

## 🔥 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Name it "Sefrou Smart City"
4. Enable Google Analytics (optional)
5. Create the project

### 2. Add Android App
1. In Firebase Console, click "Add app" → Android
2. Package name: `com.sefrou.smartcity`
3. Download `google-services.json`
4. Place it in `android/app/`
5. Follow the setup instructions

### 3. Add iOS App
1. In Firebase Console, click "Add app" → iOS
2. Bundle ID: `com.sefrou.smartcity`
3. Download `GoogleService-Info.plist`
4. Add to Xcode project
5. Follow the setup instructions

### 4. Configure Firebase Options
Update `lib/firebase_options.dart` with your Firebase credentials:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### 5. Enable Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Start in test mode (for development)
4. Choose region: `europe-west1` (closest to Morocco)

### 6. Set Firestore Security Rules
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to all collections
    match /{document=**} {
      allow read: if true;
    }
    
    // Allow write access only to authenticated users
    match /duty_schedules/{document=**} {
      allow write: if request.auth != null;
    }
    
    match /pharmacies/{document=**} {
      allow write: if request.auth != null;
    }
    
    match /services/{document=**} {
      allow write: if request.auth != null;
    }
  }
}
```

## 📁 Firestore Collections

### duty_schedules
```json
{
  "id": "doc_id",
  "pharmacyId": "pharmacy_1",
  "pharmacyName": "Pharmacie Al-Amal",
  "startDate": "2026-05-08T20:00:00Z",
  "endDate": "2026-05-09T08:00:00Z",
  "isActive": true,
  "notes": "Night duty"
}
```

### pharmacies
```json
{
  "id": "pharmacy_1",
  "name": "Pharmacie Al-Amal",
  "address": "Rue Mohammed V, Sefrou",
  "phone": "+212 5XX XXX XXX",
  "latitude": 33.8333,
  "longitude": -5.2333,
  "isOpen": true,
  "openingHours": "08:00-20:00",
  "website": "https://example.com",
  "rating": 4.5
}
```

### services
```json
{
  "id": "service_1",
  "category": "emergency",
  "name": "Civil Protection",
  "phone": "15",
  "description": "Emergency services"
}
```

## 🚀 Features Implemented

### DutyBloc
- ✅ Fetch duty schedules
- ✅ Real-time listening with streams
- ✅ Add new duty schedule
- ✅ Update duty schedule
- ✅ Delete duty schedule
- ✅ Get current duty pharmacy

### FirebaseService
- ✅ Duty schedule management
- ✅ Real-time streams
- ✅ Generic CRUD operations
- ✅ Error handling

### Real-time Updates
- ✅ Automatic duty pharmacy detection
- ✅ Live schedule updates
- ✅ Stream-based state management

## 📝 Usage Example

```dart
// Listen to duty schedules
context.read<DutyBloc>().add(const ListenToDutySchedules());

// Add new duty schedule
final schedule = DutySchedule(
  id: 'new_id',
  pharmacyId: 'pharmacy_1',
  pharmacyName: 'Pharmacie Al-Amal',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(hours: 12)),
  isActive: true,
);
context.read<DutyBloc>().add(AddDutySchedule(schedule));
```

## 🔐 Security Considerations

1. **Test Mode**: Only use for development
2. **Production Rules**: Implement proper authentication
3. **API Keys**: Keep Firebase config secure
4. **Data Validation**: Validate all inputs before saving

## 🎯 Next Steps

1. **Authentication**
   - Implement admin login
   - Role-based access control

2. **Admin Panel**
   - Manage duty schedules
   - Update pharmacy information
   - Manage services

3. **Notifications**
   - Push notifications for duty changes
   - Real-time alerts

4. **Analytics**
   - Track app usage
   - Monitor pharmacy searches
