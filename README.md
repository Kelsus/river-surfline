# Arkansas River Flow Widget

A Lock Screen widget for iOS that displays the current flow (CFS) of the Arkansas River at Salida, CO, with color-coded trend indication.

## Features

- Displays current river flow in CFS
- Color-coded trend indication:
  - Green: River is rising
  - Red: River is falling
  - Default: Flow is stable
- Hourly updates and refresh when Lock Screen becomes active
- Works with iOS 16+ Lock Screen widgets

## Setup Instructions

### Step 1: Create a new iOS App with Widget Extension

1. Open Xcode and create a new iOS App project
2. Go to File > New > Target
3. Select "Widget Extension" and click Next
4. Name your widget (e.g., "ArkansasRiverWidget")
5. Make sure "Include Configuration Intent" is NOT checked
6. Click Finish

### Step 2: Integrate This Package

1. In your Xcode project, go to File > Add Packages
2. Click the "+" button and select "Add Local Package..."
3. Navigate to this package's directory and select the Package.swift file
4. Click Add Package
5. In the next dialog, select your widget extension target and click Add Package

### Step 3: Update Your Widget Code

1. Open your widget extension's main Swift file (likely named something like `YourWidgetName.swift`)
2. Replace the contents with the following:

```swift
import WidgetKit
import SwiftUI
import ArkansasRiverWidget

@main
struct YourWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        ArkansasRiverWidget()
    }
}
```

### Step 4: Configure Widget Info.plist

1. Find your widget extension's Info.plist file
2. Add the following keys:
   - Key: `NSAppTransportSecurity`
     - Type: Dictionary
     - Add subkey: `NSAllowsArbitraryLoads`
     - Value: `YES`

### Step 5: Build and Test

1. Select your app target in the scheme selector
2. Choose an iOS 16+ simulator or device
3. Build and run your app
4. The widget should appear in the widget gallery on your device

### Step 6: Add to Your iPhone Lock Screen

1. On your iPhone running iOS 16 or later, long press on your Lock Screen
2. Tap the "Customize" button
3. Tap on an empty widget slot in the Lock Screen
4. Find your widget in the widget gallery and select it
5. Tap "Done" to save your changes

## Usage

Once added to your Lock Screen, the widget will automatically fetch and display the current river flow. The color will change based on the trend over the past day:

- Green: The river level is rising (more than 5 CFS increase)
- Red: The river level is falling (more than 5 CFS decrease)
- Default color: The river level is stable (less than 5 CFS change)

The widget updates hourly and whenever your Lock Screen becomes active.

## Troubleshooting

- If the widget displays 0 CFS, it may be having trouble connecting to the Colorado DWR API
- Make sure your device has an internet connection
- If problems persist, try removing and re-adding the widget

## Privacy

This widget only accesses publicly available water flow data from the Colorado DWR. It does not collect, store, or transmit any personal information.
