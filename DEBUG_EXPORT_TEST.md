# 🧪 Export Debug Test Guide

## Step-by-Step Testing Process

### 1️⃣ Launch App & Check Console
```bash
flutter run
```
**Look for these logs:**
- `🔄 Loading JavaScript libraries...`
- `✅ html2canvas loaded (X characters)`
- `✅ jsPDF loaded (X characters)`
- `✅ JavaScript libraries loaded successfully`

### 2️⃣ Test JavaScript Libraries
1. Tap the **🐛 Debug** button in the app bar
2. Check console for:
   ```
   🧪 === LIBRARY TEST START ===
   html2canvas available: true
   jsPDF available: true
   ✅ html2canvas is ready
   ✅ jsPDF is ready
   🧪 === LIBRARY TEST END ===
   ```

### 3️⃣ Test Permissions
1. Tap the **🔒 Security** button in the app bar
2. Grant any requested permissions
3. Check console for permission status

### 4️⃣ Test PDF Export
1. Tap **📄 Download PDF** button
2. **Expected Console Output:**
   ```
   📸 Starting PDF export...
   📸 Capturing element: [object HTMLBodyElement]
   📸 Canvas created: 800x1200
   📄 PDF generated, size: 50000 characters
   📄 Received PDF data from WebView: 50000 characters
   📄 Base64 data length: 40000
   📄 PDF bytes length: 30000
   📄 PDF saved to: /path/to/file.pdf
   ```

### 5️⃣ Test Image Export
1. Tap **🎞 Download PPTX** button
2. **Expected Console Output:**
   ```
   🖼️ Starting image capture...
   🖼️ Capturing element: [object HTMLBodyElement]
   🖼️ Canvas created: 800x1200
   🖼️ Image data generated, size: 60000 characters
   🖼️ Received image data from WebView: 60000 characters
   🖼️ Image saved to: /path/to/file.png
   ```

## 🚨 Common Issues & Solutions

### Issue: Libraries Not Loading
**Symptoms:** `❌ html2canvas is NOT available`
**Solution:** Check `assets/js/` files exist and are properly referenced in `pubspec.yaml`

### Issue: Permission Denied
**Symptoms:** `Failed to save PDF: Permission denied`
**Solution:** Grant storage permissions manually in device settings

### Issue: Empty/Blank Export
**Symptoms:** `PDF bytes length: 0` or blank files
**Solution:** 
- Check WebView content is fully loaded
- Verify JavaScript console shows successful capture
- Try increasing delay before export

### Issue: JavaScript Errors
**Symptoms:** `ERROR:` messages in console
**Solution:**
- Check network connectivity for any external resources
- Verify WebView settings allow file access
- Try on different device/emulator

## 🎯 Success Indicators
- ✅ Libraries load without errors
- ✅ Console shows capture progress
- ✅ Files are created with non-zero size
- ✅ Files can be opened in external apps
- ✅ Share dialog appears after export

## 📱 Device-Specific Notes
- **Android 13+**: Requires media permissions
- **Emulator**: May have different performance than real device
- **Real Device**: Better WebView performance, more accurate testing