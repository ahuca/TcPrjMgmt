## [0.4.1](https://github.com/ahuca/TcPrjMgmt/compare/v0.4.0...v0.4.1) (2023-11-11)


### 🛠 Fixes

* synthetically bump the version due to earlier PSGallery hickups ([7220330](https://github.com/ahuca/TcPrjMgmt/commit/7220330256d25db71bff7e2eb7d6467c44c124dc))

## [0.4.0](https://github.com/ahuca/TcPrjMgmt/compare/v0.3.5...v0.4.0) (2023-11-11)


### ⚠ BREAKING CHANGES

* `Close-DteInstace` (typo) renamed to `Close-DteInstance`

### :scissors: Refactor

* extracted function `Remove-SideEffects` ([f1d2830](https://github.com/ahuca/TcPrjMgmt/commit/f1d283057d0632bab159b29b1df6fe3f06031920))
* improved resiliency of `TcLibrary` functions ([90167de](https://github.com/ahuca/TcPrjMgmt/commit/90167de2a223d5236cbf97d2997e7a76d80c8c58))
* made `Path` parameter mandatory for `New-DummyTwincatSolution` ([2395b49](https://github.com/ahuca/TcPrjMgmt/commit/2395b4904e9d9b627dfc9aa385c57827d3f920b1))
* removed unnecessary message filtering in several locations ([851af4f](https://github.com/ahuca/TcPrjMgmt/commit/851af4f45b210dcd334623f89ce89c8cf585f468))


### 📔 Docs

* added shields to README ([52d67ef](https://github.com/ahuca/TcPrjMgmt/commit/52d67ef31f427c84ab6522067b45418711982359))
* fixed missing changelog entry ([c58a106](https://github.com/ahuca/TcPrjMgmt/commit/c58a1066a3b77243c0e3864612a8e041aed2d69c))


### 🧪 Tests

* using Pester's `$TestDrive` instead of system temp ([636614b](https://github.com/ahuca/TcPrjMgmt/commit/636614b476ffe60348593497b8e189bfeea17dc7))


### 🚀 Features

* `Export-TcProject` can self service its own DTE instance ([9be9fd7](https://github.com/ahuca/TcPrjMgmt/commit/9be9fd7bcecef891a94665bec8ad0e8882768f8a))
* `Install-TcLibrary` can self service its own DTE instance ([5a0f9fd](https://github.com/ahuca/TcPrjMgmt/commit/5a0f9fd2631a0fc0b0e7ae28136805de953dbb66))
* `Uninstall-TcLibrary` can self service its own DTE instance ([208ed2e](https://github.com/ahuca/TcPrjMgmt/commit/208ed2efd10a1e6c674dc2b83f1b0c2f92aeddbe))
* implemented dynamic parameter to `Export-TcProject` ([bb99adc](https://github.com/ahuca/TcPrjMgmt/commit/bb99adce23c7db8efeceda669fbd9f41931f3fce))


### 🛠 Fixes

* added variable initialization to `TcLibrary` functions ([3009415](https://github.com/ahuca/TcPrjMgmt/commit/3009415051e21eb8156213f67085ccb07e25a62f))
* fixed clean up steps in `TcLibrary` functions ([4341ac7](https://github.com/ahuca/TcPrjMgmt/commit/4341ac77d7ba2aaf0e429f0d95a47d13ec690eab))
* fixed typo in file name `Close-DteInstace.ps1` ([781eb42](https://github.com/ahuca/TcPrjMgmt/commit/781eb42338ce4d634793e610d854774529e61e06))
* fixed typo in the name of function `Close-DteInstace` ([048b73e](https://github.com/ahuca/TcPrjMgmt/commit/048b73ef7483145ba26b5ed83dd84ef1e4ddb4c0))

## [0.3.5](https://github.com/ahuca/TcPrjMgmt/compare/v0.3.4...v0.3.5) (2023-11-07)


### 🚀 Features

* added `Update-PlcProjectVersion` [#4](https://github.com/ahuca/TcPrjMgmt/issues/4) ([a5a9739](https://github.com/ahuca/TcPrjMgmt/commit/a5a97398804189a8dcb0ad4e6cc142acc357ef3d))

### :scissors: Refactor

* refactored `Step-PlcProjectVersion.ps1`

## [0.3.4](https://github.com/ahuca/TcPrjMgmt/compare/v0.3.3...v0.3.4) (2023-11-06)


### 🦊 CI/CD

* updated workflow ([ddc23f6](https://github.com/ahuca/TcPrjMgmt/commit/ddc23f64cdc14cef850d798ab60018ba5d95972e))


### 🛠 Fixes

* fixed  `Update-FunctionsToExport` ([b937aa5](https://github.com/ahuca/TcPrjMgmt/commit/b937aa51dcd0f8de2c7f23c18349a4cf3a06b78c))

## [0.3.3](https://github.com/ahuca/TcPrjMgmt/compare/v0.3.2...v0.3.3) (2023-11-06)


### :scissors: Refactor

* Improved path handling ([71b2c5a](https://github.com/ahuca/TcPrjMgmt/commit/71b2c5a69f3f226eb45d88aa47997a49c5b5edb4))


### 🦊 CI/CD

* Added `appveyor.yml` ([86944f7](https://github.com/ahuca/TcPrjMgmt/commit/86944f74257bdc63a04427a97decff7990e5ca35))
* added `semantic-release` ([412c132](https://github.com/ahuca/TcPrjMgmt/commit/412c132ab66cc62a504444a95ef898112aa57c62))


### 🚀 Features

* added scripts for updating module info ([e30268d](https://github.com/ahuca/TcPrjMgmt/commit/e30268daabbc8610809b4759753289f4d3ec03a6))


### Other

* updated module manifest ([e85bfb5](https://github.com/ahuca/TcPrjMgmt/commit/e85bfb50b93a995bbba4d401be3833fb2be78a14))
