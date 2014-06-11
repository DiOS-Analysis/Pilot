# DiOS Pilot

The DiOS Pilot comprises several client components that need to be installed on each client iOS device. 

First, the `SBServerTweak` (also known as Controller) is the frontmost client component that receives instructions from the [DiOS Worker] such as purchasing apps from the App Store, installing and executing apps and delegating automatic UI exploration to the executor component. The controller is implemented in Objective-C and is integrated into SpringBoard via library injection. During initialization of the controller library an HTTP web server is spawned providing a REST-based web service interface to the worker component. Further, on-device communication between all involved client components is realized using the distributed notification concept of iOS.

The AAExecutorDaemon (Executor) is responsible for automatically exploring an app's user interface and for simulating user interaction. For this, several execution strategies were implemented which provide different granularity levels of UI exploration. To separate automation code from the actual app code, the executor was implemented as iOS background daemon and makes use of the UI Automation API.

The `AAClientLib` is a static library that simplifies the development of DiOS analyzer plugins. It receives notifications from the controller and provides a clean interface to report analysis results to the backend. Please see [BasicAnalyzer](https://github.com/DiOS-Analysis/BasicAnalyzer) for a usage example. 


## Requirements
  * theos (installed to `/opt/theos`) <https://github.com/DHowett/theos>


See [Initial Setup](https://github.com/DiOS-Analysis/DiOS/wiki/Initial-Setup) and [Running DiOS](https://github.com/DiOS-Analysis/DiOS/wiki/Running-DiOS) for detailed build and setup instructions.
