# nextcloud-neon

A beautiful convergent cross-platform client for Nextcloud written in Flutter.

See [here](packages/neon/README.md) for screenshots and other material regarding the app.

This repository not only contains the Neon app, but also a Nextcloud client written in Dart.  
The client will replace https://github.com/jld3103/dart-nextcloud which is an older unmaintained client I wrote some time ago.  

The development of this app and client just started, there will be a lot of changes and new features coming soon.

Additional documentation is very much appreciated. If you find something that you think should be documented, please open an issue or pull request.

## Development and support

Either open an issue if you exactly know what you need or your problem is, otherwise please ask in Matrix.
The Matrix space is here: https://matrix.to/#/#nextcloud-neon:matrix.org.  
There are separate rooms for the client and the app. If you don't know which channel you should use if you have a question, just use the app channel.

## Features

There are a lot of planned features that still need help. Go [here](https://github.com/jld3103/nextcloud-neon/issues?q=is%3Aopen+is%3Aissue+label%3Afeature) and grab an issue to work on.  
Even if a new feature is not listed yet, please open an issue.

- :heavy_check_mark: Fully supported
- :white_check_mark: Fully supported, but new features planned
- :warning: Partially supported
- :rocket: Planned

| App           | Status                                                                                                                                             |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| Activity      | :rocket:                                                                                                                                           |
| Calendar      | :rocket:                                                                                                                                           |
| Contacts      | :rocket:                                                                                                                                           |
| Cookbook      | :rocket:                                                                                                                                           |
| Files         | :white_check_mark: [See here](https://github.com/jld3103/nextcloud-neon/issues?q=is%3Aopen+is%3Aissue+label%3A%22neon%3A+files%22+label%3Afeature) |
| News          | :white_check_mark: [See here](https://github.com/jld3103/nextcloud-neon/issues?q=is%3Aopen+is%3Aissue+label%3Afeature+label%3A%22neon%3A+news%22)  |
| Notes         | :heavy_check_mark:                                                                                                                                 |
| Notifications | :heavy_check_mark:                                                                                                                                 |
| Tasks         | :rocket:                                                                                                                                           |


## Platform support

Except for web, Neon should run on all supported Flutter platforms in the future.  
Right now this is not the case, only Android and Linux are supported and tested, but this can easily be extended to other platforms.  

The features and problems of all platforms should be considered when implementing new features.
