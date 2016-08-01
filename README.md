# LOOP iOS Sample - Trips

## Prerequisites:
  * You will need the latest version of XCode (7.3.1 or greater) to run this sample app.
  * You will need to install [Carthage](https://github.com/Carthage/Carthage)

## Build instructions:
These instructions will get you a copy of the Location and observation platform (LOOP) sample app that will download and display trips.

  0. Signup for a LOOP account and create an app on the [Loop Developer Site](https://www.loop.ms)
  0. Get the sample app
    0. Clone this sample app `https://github.com/Microsoft/Loop-Sample-Trips-IOS.git`
    0. Open it in XCode
    0. In the `Keys.xcconfig` file provide values for the `LOOP_APP_ID_PROP` and `LOOP_APP_TOKEN_PROP` using your LOOP app ID and token.
  0. Create test users in the user dashboard at the [LOOP Developer Site](https://www.loop.ms)
  0. In the `Keys.xcconfig` file provide values for the `LOOP_USER_ID_PROP` and `LOOP_DEVICE_ID_PROP` using a test user id and device id from the dashboard.
  0. From the command line in the project directory run `carthage update --platform iOS`
  0. Build and run the app

After the app runs for a while you will see your trips and drives. This should only take a few hours but no longer than 24 hours as you move between locations.
