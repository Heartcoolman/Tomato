#!/usr/bin/env python3
"""
Script to add new Swift files to Xcode project
"""

import subprocess
import sys

files_to_add = [
    'TomatoTimer/Utilities/GradientLibrary.swift',
    'TomatoTimer/Views/Components/GradientButton.swift',
    'TomatoTimer/Views/Components/StatusCard.swift',
    'TomatoTimer/Views/Components/ModePillSelector.swift',
    'TomatoTimer/Views/Components/ParticleSystem.swift',
    'TomatoTimer/Views/Navigation/DockNavigationBar.swift'
]

print("=" * 60)
print("Adding new Swift files to Xcode project...")
print("=" * 60)

print("\n📋 Files to add:")
for file in files_to_add:
    print(f"  - {file}")

print("\n" + "=" * 60)
print("MANUAL STEPS TO ADD FILES TO XCODE:")
print("=" * 60)

print("""
Since automatic modification of .pbxproj is complex, please follow these steps:

1. Open TomatoTimer.xcodeproj in Xcode

2. Right-click on 'Utilities' folder in Project Navigator
   - Select "Add Files to TomatoTimer..."
   - Navigate to: TomatoTimer/Utilities/
   - Select: GradientLibrary.swift
   - ✅ Check "Add to targets: TomatoTimer"
   - Click "Add"

3. Right-click on 'Components' folder under Views
   - Select "Add Files to TomatoTimer..."
   - Navigate to: TomatoTimer/Views/Components/
   - Select ALL of these:
     • GradientButton.swift
     • StatusCard.swift  
     • ModePillSelector.swift
     • ParticleSystem.swift
   - ✅ Check "Add to targets: TomatoTimer"
   - Click "Add"

4. Right-click on 'Views' folder
   - Select "New Group" → Name it "Navigation"
   - Right-click on new 'Navigation' folder
   - Select "Add Files to TomatoTimer..."
   - Navigate to: TomatoTimer/Views/Navigation/
   - Select: DockNavigationBar.swift
   - ✅ Check "Add to targets: TomatoTimer"
   - Click "Add"

5. Build the project (Cmd+B) to verify

Alternatively, you can drag and drop the files directly into Xcode!
""")

print("=" * 60)
print("\nOR use this quick Xcode command:")
print("=" * 60)

# Generate xcodebuild commands
for file in files_to_add:
    print(f'\n# Add {file}')
    print(f'# (This must be done in Xcode GUI)')

print("\n✅ After adding files, run: xcodebuild build -scheme TomatoTimer")

