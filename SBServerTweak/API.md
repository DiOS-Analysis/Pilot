# Pilot API Documentation


### Install Apps

#### `POST /install/appstore`

Request:

  - appInfo
  - accountIdentifier
  - callback  


#### `POST /install/cydia`

Request:

- bundleId  


#### `GET /status`

Status dictionary


#### `GET /applications`

List all installed applications


#### `POST /open/<bundleId>`

The `bundleId` as parameter


#### `GET /inject`

Request:

- process
- command