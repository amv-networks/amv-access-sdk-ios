[![License](https://img.shields.io/github/license/amv-networks/amv-access-sdk-ios-reference-app.svg?maxAge=2592000)](https://github.com/amv-networks/amv-access-sdk-ios-reference-app/blob/master/LICENSE)

# AMVKit #

## What is this repository for? ##

This repository contains the *Xcode 9* project for AMVKit.  
The kit has functionality for *downloading*, *storing* and *using* a **Device Certificate**.  
The same is done for **Access Certificates** with the additional functionality to *delete* them.

Furthermore, the kit enables *easy* bluetooth broadcasting and connection with *access certificates*.  
Lastly, it has 2 easy to use methods for vehicle doors – *lock* and *unlock*.

## How do I get set up? ##

* Clone it with some application or download the repository (not recommended)

There are 2 ways to build the **AMVKit** framework

* On the commandline (recommended)
    * execute `sh BuildScript.sh -deviceOnly` for a *device-only* framework
    * execute `sh BuildScript.sh` for a *universal* framework (recommended)
* Open the *AMVKit.xcodeproj* with Xcode 9+
    * Build against *AMVKit* for a *device-only* framework
	* Build against *AMVKit Universal* for a *universal* framework

## Using the frameworks in an app ##

### Embedding ###

* Drag all 4 frameworks into *Embedded Binaries* in Xcode project view (check Copy)
    * Can leave only *AMVKit* in *Linked Frameworks...* list (of the 4)
* Before uploading to *iTunes Connect* the frameworks need to be **thinned** (simulator slices removed; only *universal* frameworks):
    * Navigate to each *framework*'s folder in Terminal (inside the .framework)
    * Execute the *AppStoreCompatible.sh* script there (also contains the instructions)

### Main Methods ###

After the *AMVKit* has been imported in an app source file, all the functionality is accessible through it's *singleton*.
```swift
static var AMVKit.shared
```

To start using AMVKit, it has to be *initialised*.  
The *accessSdkOptions* contains the URL, credentials and optional identity to access the amv-access-api backend.
The *handler*-block is invoked when the *Device Certificate* has been loaded from the local database, or when not present, downloaded from the server.  
This also *initialises* High Mobility's frameworks, or when any step is unsuccessful, returns an error.
```swift
func initialise(accessSdkOptions newAccessSdkOptions, handler done: @escaping (Result<DeviceCertificate>) -> Void) throws
```

After the kit has been initialised, *Access Certificates* can be loaded from the local database, or new ones downloaded from the server (overrides the local database on successful download).  
Downloading new certificates also registers them with High Mobility's frameworks.
```swift
func getAccessCertificates() -> [AccessCertificate]?
```
```swift
func refreshAccessCertificates(_ done: @escaping (Result<[AccessCertificate]>) -> Void) throws
```

To connect to a vehicle, an *Access Certificate* has to be chosen and then passed to the method.  
This starts *bluetooth* broadcasting with the vehicle serial in the advertisment data.  
After a suitable vehicle has been found, the connection is established, authenticated and the initial state is queried.  
The method's *handler*-block is invoked **each time** the device receives new data from the vehicle, or once for a disconnect.
```swift
func connect(to accessCertificate: AccessCertificate, handler: @escaping (Result<VehicleUpdate>) -> Void) throws
```

### Additional Methods ###

Deleting an *Access Certificate* first tries to delete it from the *server*.  
If successful, it's deleted from the *local database* as well and the *done*-block is invoked with the deleted certificate for reference.
```swift
func deleteAccessCertificate(_ accessCertificate: AccessCertificate, done: @escaping (Result<AccessCertificate>) -> Void) throws
```

Disconnect from a connected vehicle.  
In addition, this *stops* the bluetooth broadcasting (if active) – can be used before a connection to a vehicle is established.
```swift
func disconnect()
```

Reset the *local database* by removing all saved *access certificates*, the *device certificate* and the *keys*.
```swift
func resetDatabase()
```

### Commands ###

Before sending commands to the vehicle, you have to wait unitl any previous query is finished.

Lock the doors - successful (or not) response is returned in the *connect*-method's *handler*-block.
```swift
func sendCommand(.lockDoors) throws
```

Unlock the doors - successful (or not) response is returned in the *connect*-method's *handler*-block.
```swift
func sendCommand(.unlockDoors) throws
```

### Misc ###

All *async* methods return the result as an *enum* value.
```swift
enum Result<T> {
    case error(Error)
    case success(T)
}
```

## Tests ##

Implemented *tests* for the *AMVKit*:

* Access Certificates *downloading* and parsing
* Device Certificates *downloading* and parsing
* Key pair *generation*  

To run them, open the *Xcode* project, choose *AMVKit* as the **target Scheme** and *Test*.

# license
The project is licensed under the Apache License. See [LICENSE](LICENSE) for details.
