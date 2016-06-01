# Loop iOS Sample - Setting up test users

Note: You will need the latest version of XCode (7.3.1) to run this sample app. 

These instructions will get you a copy of a Loop sample app for sending test signals to Loop.

1. If you haven’t already, signup for a loop account (it takes seconds - https://developer.dev.loop.ms/) 
2. Create an app to get your loop app key and secret token
3. Clone this sample app (`git clone https://github.com/Microsoft/Loop-Sample-Trips-IOS.git`), and open it in XCode. Replace the `YOUR_APP_ID` and `YOUR_APP_TOKEN` constant in `AppDelegate.swift` with your loop app key and secret token. 
4. Run `carthage update --platform iOS`
5. Replace the `YOUR_USER_ID` and `YOUR_DEVICE_ID` with a test user id generated through developer portal
6. Run the app. 

After this is done, you can send test signals to Loop and see them in your dashboard.
. 
