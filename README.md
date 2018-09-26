## KSOThumbnailKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](http://img.shields.io/cocoapods/v/KSOThumbnailKit.svg)](http://cocoapods.org/?q=KSOThumbnailKit)
[![Platform](http://img.shields.io/cocoapods/p/KSOThumbnailKit.svg)]()
[![License](http://img.shields.io/cocoapods/l/KSOThumbnailKit.svg)](https://github.com/Kosoku/KSOThumbnailKit/blob/master/license.txt)

KSOThumbnailKit contains classes used to generate and cache thumbnail images from a variety of source URLs. It relies on the [Stanley](https://github.com/Kosoku/Stanley), [Ditko](https://github.com/Kosoku/Ditko), and [Loki](https://github.com/Kosoku/Loki) frameworks. Support is provided for images, movies, pdfs, html, plain text, rtf and a variety of other formats. Some formats are not supported on tvOS because the WebKit framework is not available on that platform.

### Installation

You can install *KSOThumbnailKit* using [cocoapods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage), or as a framework. When installing as a framework, ensure you also link to [Stanley](https://github.com/Kosoku/Stanley), [Ditko](https://github.com/Kosoku/Ditko), and [Loki](https://github.com/Kosoku/Loki) as *KSOThumbnailKit* relies on them.

### Dependencies

Third party:

- [Stanley](https://github.com/Kosoku/Stanley)
- [Ditko](https://github.com/Kosoku/Ditko)
- [Loki](https://github.com/Kosoku/Loki)

Apple:

- `AVFoundation`, (`iOS`/`tvOS`/`macOS`)
- `MobileCoreServices`, (`iOS`/`tvOS`)
- `WebKit`, (`iOS`/`macOS`)
- `QuickLook`, (`macOS`)
