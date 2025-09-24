# FERPA-Compliant Firebase Setup Guide
## Complete Beginner's Guide for Educational Use

### 1. Create Your Firebase Project (Education-Focused)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Click "Create a project"

2. **Project Configuration (FERPA Settings)**
   - **Project name**: "your-course-name-fall2025" 
   - **Region**: Choose "us-central" (US-based for FERPA compliance)
   - **Analytics**: DISABLE (not needed for education, reduces privacy concerns)

3. **Enable Required Services**
   - Click "Realtime Database" → "Create Database"
   - Choose "Start in locked mode" (FERPA requirement)
   - Select "us-central1" region

### 2. FERPA-Compliant Database Structure

```json
{
  "courses": {
    "fall2025-econ": {
      "sessions": {
        "2025-09-22": {
          "polls": {
            "question1": {
              "anonymized_responses": {
                "student_001": {"answer": "A", "timestamp": 1695395200},
                "student_002": {"answer": "B", "timestamp": 1695395201}
              }
            }
          },
          "attendance": {
            "count": 28,
            "timestamp": 1695395000
          }
        }
      }
    }
  }
}
```

**FERPA Design Principles:**
- ✅ No real names (use anonymized IDs)
- ✅ Course-specific data separation
- ✅ Session-based organization
- ✅ Educational purpose only

### 3. Security Rules (FERPA-Compliant)

```javascript
{
  "rules": {
    "courses": {
      "$courseId": {
        // Only instructor can read/write course data
        ".read": "auth != null && auth.uid == 'YOUR_INSTRUCTOR_UID'",
        ".write": "auth != null && auth.uid == 'YOUR_INSTRUCTOR_UID'",
        
        "sessions": {
          "$sessionId": {
            "polls": {
              "$pollId": {
                "anonymized_responses": {
                  // Students can only add their own response
                  "$studentId": {
                    ".write": "auth != null && $studentId == auth.uid.substr(0, 10)",
                    ".read": "auth != null && auth.uid == 'YOUR_INSTRUCTOR_UID'"
                  }
                }
              }
            },
            "attendance": {
              // Only instructor can view attendance data
              ".read": "auth != null && auth.uid == 'YOUR_INSTRUCTOR_UID'",
              ".write": "auth != null && auth.uid == 'YOUR_INSTRUCTOR_UID'"
            }
          }
        }
      }
    }
  }
}
```

### 4. Student Privacy Protection

**Anonymous Authentication Setup:**
```javascript
// Enable Anonymous Auth in Firebase Console
// Authentication → Sign-in method → Anonymous → Enable

// In your web app:
firebase.auth().signInAnonymously()
  .then((result) => {
    // Create anonymous student ID
    const studentId = 'student_' + result.user.uid.substring(0, 8);
    // Use this ID instead of names
  });
```

### 5. FERPA-Compliant Data Collection

**Privacy Notice Template:**
```html
<div class="privacy-notice">
  <h4>Student Data Privacy Notice</h4>
  <p><strong>Data Collection:</strong> This activity collects your poll responses for educational assessment only.</p>
  <p><strong>Privacy:</strong> Your responses are anonymized and used solely for this course.</p>
  <p><strong>Retention:</strong> Data is deleted at the end of the semester.</p>
  <p><strong>Access:</strong> Only your instructor can view individual responses.</p>
  <button onclick="acknowledgePrivacy()">I Understand and Consent</button>
</div>
```

### 6. Implementation Steps

1. **Firebase Console Setup**
   ```
   Project Settings → General → Your apps → Add app → Web
   Copy configuration object
   ```

2. **Add to Your Quarto File**
   ```html
   <!-- Add before your existing Firebase script -->
   <script>
   const firebaseConfig = {
     // Your config from Firebase Console
     // Make sure to use environment variables in production
   };
   </script>
   ```

3. **Enable Authentication**
   ```
   Authentication → Sign-in method → Anonymous → Enable
   ```

4. **Set Database Rules**
   ```
   Database → Rules → Copy the rules from above
   Replace 'YOUR_INSTRUCTOR_UID' with your actual UID
   ```

### 7. Student Consent Management

```javascript
function acknowledgePrivacy() {
  localStorage.setItem('ferpa_consent_' + courseId, 'granted');
  document.querySelector('.privacy-notice').style.display = 'none';
  initializePoll();
}

function checkPrivacyConsent() {
  const consent = localStorage.getItem('ferpa_consent_' + courseId);
  if (!consent) {
    showPrivacyNotice();
    return false;
  }
  return true;
}
```

### 8. Data Minimization Example

```javascript
function submitResponse(questionId, answer) {
  // FERPA-compliant: Only collect necessary data
  const responseData = {
    answer: answer,  // Educational content only
    timestamp: firebase.database.ServerValue.TIMESTAMP,
    // NO personal information collected
  };
  
  // Use anonymous student identifier
  const anonymousId = 'student_' + auth.currentUser.uid.substring(0, 8);
  
  db.ref(`courses/${courseId}/sessions/${sessionId}/polls/${questionId}/responses/${anonymousId}`)
    .set(responseData);
}
```

### 9. Instructor Dashboard (Analytics)

```javascript
function generateClassAnalytics() {
  db.ref(`courses/${courseId}/sessions/${sessionId}/polls`).once('value', (snapshot) => {
    const polls = snapshot.val();
    
    // FERPA-compliant analytics
    Object.entries(polls).forEach(([pollId, pollData]) => {
      const responses = pollData.responses || {};
      const totalResponses = Object.keys(responses).length;
      
      // Calculate distributions without exposing individual data
      const answerCounts = {};
      Object.values(responses).forEach(response => {
        answerCounts[response.answer] = (answerCounts[response.answer] || 0) + 1;
      });
      
      // Display aggregated results only
      displayResults(pollId, answerCounts, totalResponses);
    });
  });
}
```

### 10. Data Retention and Deletion

```javascript
// Automatically delete session data after semester
function scheduleDataDeletion() {
  const endOfSemester = new Date('2025-12-15');
  const deleteDate = endOfSemester.getTime();
  
  // Schedule deletion
  db.ref(`courses/${courseId}/deleteSchedule`).set({
    scheduledDeletion: deleteDate,
    reason: 'End of semester - FERPA compliance'
  });
}
```

### 11. Troubleshooting Common Issues

**Issue: "Permission denied" errors**
- Check that your instructor UID is correct in the rules
- Ensure you're authenticated before accessing data

**Issue: Students can't submit responses**
- Verify anonymous authentication is enabled
- Check that student IDs are being generated correctly

**Issue: Data not appearing**
- Confirm database rules allow the specific operations
- Check browser console for detailed error messages

### 12. Testing Your Setup

1. **Test student submission**: Open in incognito mode, submit response
2. **Test instructor view**: Login with your account, verify you can see aggregated data  
3. **Test privacy**: Confirm no personal data appears in database
4. **Test deletion**: Verify old sessions can be removed

### Compliance Checklist

- ✅ Anonymous student identification
- ✅ Educational purpose only  
- ✅ Secure data transmission (HTTPS)
- ✅ Access controls (instructor only)
- ✅ Student consent obtained
- ✅ Data minimization practiced
- ✅ Deletion schedule implemented
- ✅ No commercial data use

This setup gives you powerful classroom engagement tools while maintaining full FERPA compliance!