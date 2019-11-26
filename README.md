# STAssignment
1. Enter radius in the text field and press "Start Monitoring" button.
2. It will ask you to allow the app to grant GPS access.
3. Allow the GPS access to the app, it will save your current location is the location coordinate, 
and use the radius given in the text field to make the region and start monitoring.
4. Once the monitoring begins, it will update the message label about the status.

Please note that the Wifi functionality is implemented but it is currently unusable due to the recent changes in the framework.
From iOS 12 and onwards, wifi info needs the permission in the Entitlement, and to create that we need Paid developers account, 
which I dont have at the moment. The code is done, but since the entitlement is not added, the app will ignore the Wifi.
