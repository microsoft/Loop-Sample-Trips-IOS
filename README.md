# Loop iOS Sample - Trips

## Prerequisites:
  * You will need the latest version of XCode (7.3.1 or greater) to run this sample app.
  * You will need to install [Carthage](https://github.com/Carthage/Carthage)

## Build instructions:
These instructions will get you a copy of a Loop sample app that will download user trips generated in the Loop platform and display them.

  0. If you haven’t already, signup for a Loop account and create an app on the [Loop Developer Site](https://www.loop.ms)
  0. Get the sample app
    0. Clone this sample app `https://github.com/Microsoft/Loop-Sample-Trips-IOS.git`
    0. Open it in XCode
    0. Make a copy of `Config/Keys.example.xcconfig` and call it `Config/Keys.xcconfig`
    0. In the `Keys.xcconfig` file provide values for the `LOOP_APP_ID_PROP` and `LOOP_APP_TOKEN_PROP` using your Loop app id and app token from the dashboard.
    0. Touch the `Loop Test User.xcconfig` file
  0. Create test users in the user dashboard at the [Loop Developer Site](https://www.loop.ms)
  0. In the `Keys.xcconfig` file provide values for the `LOOP_USER_ID_PROP` and `LOOP_DEVICE_ID_PROP` using a test user id and device id from the dashboard.
  0. From the command line in the project directory run `carthage update --platform iOS`
  0. Build an run the app

After the app runs for a while you will see your user's trips and drives. This should only take a few hours but no longer than 24 hours as you move between locations.
