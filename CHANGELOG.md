# Changelog

## [2.3.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v2.2.2...v2.3.0) (2025-08-26)


### Features

* **deps:** bump github.com/cloudnationhq/az-cn-go-validor in /tests ([#43](https://github.com/CloudNationHQ/terraform-azure-eg/issues/43)) ([d4d035c](https://github.com/CloudNationHQ/terraform-azure-eg/commit/d4d035c1f4831bf6c23ec3ed89adff80c20e9986))
* update source_resource_id property ([#44](https://github.com/CloudNationHQ/terraform-azure-eg/issues/44)) ([05ce0f6](https://github.com/CloudNationHQ/terraform-azure-eg/commit/05ce0f6291d761f182d47bf7e1aed1b19092bf75))

## [2.2.2](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v2.2.1...v2.2.2) (2025-07-29)


### Bug Fixes

* correct type definitions, remove duplicate keys, and align resource implementation with variable type definition ([#38](https://github.com/CloudNationHQ/terraform-azure-eg/issues/38)) ([e7ac7b9](https://github.com/CloudNationHQ/terraform-azure-eg/commit/e7ac7b9bd3490297d599982451534190e855d2d9))
* **deps:** bump github.com/cloudnationhq/az-cn-go-validor in /tests ([#37](https://github.com/CloudNationHQ/terraform-azure-eg/issues/37)) ([cb5f599](https://github.com/CloudNationHQ/terraform-azure-eg/commit/cb5f599975e3579e3cf53ed06f274548f3843a3c))
* fix naming key event subscriptions ([#41](https://github.com/CloudNationHQ/terraform-azure-eg/issues/41)) ([a01db2e](https://github.com/CloudNationHQ/terraform-azure-eg/commit/a01db2e6ba575a0ba754235bbfa46182006255e8))

## [2.2.1](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v2.2.0...v2.2.1) (2025-06-30)


### Bug Fixes

* add missing properties, including azure_function_endpoint ([#35](https://github.com/CloudNationHQ/terraform-azure-eg/issues/35)) ([d821a40](https://github.com/CloudNationHQ/terraform-azure-eg/commit/d821a4099637939840a017c4edb670e5c7df2c13))

## [2.2.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v2.1.0...v2.2.0) (2025-05-19)


### Features

* implement flexible resource naming ([#32](https://github.com/CloudNationHQ/terraform-azure-eg/issues/32)) ([72aead1](https://github.com/CloudNationHQ/terraform-azure-eg/commit/72aead1b9d3a10d5672a0758db0831745d4e7d5d))

## [2.1.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v2.0.0...v2.1.0) (2025-05-13)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#27](https://github.com/CloudNationHQ/terraform-azure-eg/issues/27)) ([88588e0](https://github.com/CloudNationHQ/terraform-azure-eg/commit/88588e09c064d7df5c850b8160611c8d5a1f9c4b))
* update all available functionality ([#30](https://github.com/CloudNationHQ/terraform-azure-eg/issues/30)) ([2b514fb](https://github.com/CloudNationHQ/terraform-azure-eg/commit/2b514fb73edbadaaa79daa6146d3deae380c0fb3))

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.5.0...v2.0.0) (2025-05-12)


### ⚠ BREAKING CHANGES

* The data structure changed, causing a recreate on existing resources.

### Features

* small refactor ([#28](https://github.com/CloudNationHQ/terraform-azure-eg/issues/28)) ([cc28500](https://github.com/CloudNationHQ/terraform-azure-eg/commit/cc285008cbb452ef7ee06132ab66e4b225b8384c))

### Upgrade from v1.5.0 to v2.0.0:

- Update module reference to: `version = "~> 2.0"`
- The property and variable resource_group is renamed to resource_group_name

## [1.5.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.4.2...v1.5.0) (2025-04-22)


### Features

* add additional advanced filter options ([#25](https://github.com/CloudNationHQ/terraform-azure-eg/issues/25)) ([fe2cbca](https://github.com/CloudNationHQ/terraform-azure-eg/commit/fe2cbca8c06f9fe752cdf2b436310c7484d1fcbd))
* **deps:** bump golang.org/x/crypto from 0.32.0 to 0.35.0 in /tests ([#23](https://github.com/CloudNationHQ/terraform-azure-eg/issues/23)) ([1d76003](https://github.com/CloudNationHQ/terraform-azure-eg/commit/1d76003dd08dd1b7db6ff8fb82b2a8d8d0e3d6ed))
* **deps:** bump golang.org/x/net from 0.34.0 to 0.38.0 in /tests ([#24](https://github.com/CloudNationHQ/terraform-azure-eg/issues/24)) ([eeeffe8](https://github.com/CloudNationHQ/terraform-azure-eg/commit/eeeffe83fe80e5cc33b708a6759d3a090e2f6f90))

## [1.4.2](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.4.1...v1.4.2) (2025-03-07)


### Bug Fixes

* fix included event types to be optional in system topics ([#20](https://github.com/CloudNationHQ/terraform-azure-eg/issues/20)) ([199a109](https://github.com/CloudNationHQ/terraform-azure-eg/commit/199a10964bde8510b6a99e8f0a98e7c177036149))

## [1.4.1](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.4.0...v1.4.1) (2025-03-07)


### Bug Fixes

* fix event grid system topic naming ([#18](https://github.com/CloudNationHQ/terraform-azure-eg/issues/18)) ([034e694](https://github.com/CloudNationHQ/terraform-azure-eg/commit/034e694f94cd64e7bf18cb1abb7a57be6a911a5f))

## [1.4.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.3.0...v1.4.0) (2025-03-05)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#15](https://github.com/CloudNationHQ/terraform-azure-eg/issues/15)) ([4188fde](https://github.com/CloudNationHQ/terraform-azure-eg/commit/4188fdeffee3ef65478a9012da32373b2fcaa617))


### Bug Fixes

* made some properties optional in eventgrid topics and corrected the custom topic usage example ([#16](https://github.com/CloudNationHQ/terraform-azure-eg/issues/16)) ([5abf66d](https://github.com/CloudNationHQ/terraform-azure-eg/commit/5abf66d41d4d89eea8f51ed3c9657733a762f6b4))

## [1.3.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.2.0...v1.3.0) (2025-01-20)


### Features

* **deps:** bump golang.org/x/crypto from 0.29.0 to 0.31.0 in /tests ([#10](https://github.com/CloudNationHQ/terraform-azure-eg/issues/10)) ([62167bc](https://github.com/CloudNationHQ/terraform-azure-eg/commit/62167bc81b69a5d32b97b82adf4e42614fc9a08f))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#13](https://github.com/CloudNationHQ/terraform-azure-eg/issues/13)) ([86d83ee](https://github.com/CloudNationHQ/terraform-azure-eg/commit/86d83ee6e8b29345a49210cdccec664f98d0284e))
* remove temporary files when deployment tests fails ([#11](https://github.com/CloudNationHQ/terraform-azure-eg/issues/11)) ([3c0aa41](https://github.com/CloudNationHQ/terraform-azure-eg/commit/3c0aa412f291f0c883c59d9fb86b5b692ebcfd98))

## [1.2.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.1.0...v1.2.0) (2025-01-06)


### Features

* add missing properties, code blocks for event subscriptions and system topic event subscriptions ([#8](https://github.com/CloudNationHQ/terraform-azure-eg/issues/8)) ([edf288c](https://github.com/CloudNationHQ/terraform-azure-eg/commit/edf288c390e1bcb3be93f2cb0b2352b29223108c))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#7](https://github.com/CloudNationHQ/terraform-azure-eg/issues/7)) ([e88d9a6](https://github.com/CloudNationHQ/terraform-azure-eg/commit/e88d9a6b94d1e4339c94f020c73e53f0781ecfb1))

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-eg/compare/v1.0.0...v1.1.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#4](https://github.com/CloudNationHQ/terraform-azure-eg/issues/4)) ([dfb15d5](https://github.com/CloudNationHQ/terraform-azure-eg/commit/dfb15d50fd703f8be4441c39eb9fbca9076b4570))

## 1.0.0 (2024-11-04)


### Features

* add initial resources ([#2](https://github.com/CloudNationHQ/terraform-azure-eg/issues/2)) ([83fc117](https://github.com/CloudNationHQ/terraform-azure-eg/commit/83fc117123050591436b8ee5831427a5978079e8))
