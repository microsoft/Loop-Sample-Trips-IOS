# LOOP iOS Sample - Trips

## Overview
This is the HockeyApp fork of the [Loop-Sample-Trips-IOS](https://github.com/Microsoft/Loop-Sample-Trips-IOS.git) project on GitHub. This is not a real fork of the project, but rather a cross-sync from GibHub to VSO. The purpose of this is to keep the HockeyApp modifications to the project private and internal for Microsoft only internal distribution and testing.

The process for building and distribution relies on HockeyApp as the distribution mechanism. The source is synce'ed to this VSO repo, then modified to support HockeyApp distribution. This requires just a few steps:
  1. Update Cartfile to include the HockeyApp SDK Framework
  1. From a command line in the project
     ```
     carthage update --platform 'iOS'
     ```
  1. Modify the main project file to include the HockeySDK.framework
  1. Modify AppDelegate.swift to include the HockeyApp SDk initialization  
     ```
     #import HockeySDK
     ```
     ```
     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         BITHockeyManager.sharedHockeyManager().configureWithIdentifier("fd8801c521a8498caa4f093c4a782f45")
         BITHockeyManager.sharedHockeyManager().startManager()
         BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation() // This line is obsolete in the crash only builds
         ...
     ```

These files are keep modified in this project and changes from the main GitHub release branch (usually the `develop` branch) are merged into working branches here and tested. Once tested the releases are imported into HockeyApp as new version releases.
