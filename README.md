# EgorTabula Scripts

[![License: MIT][license_badge]][license_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]

---

Developed with 💙 by [Egor Tabula](https://github.com/egortabula)

---

Collection of useful scripts and Mason bricks for Flutter/Dart development.

## 🧱 Bricks

| Brick                      | Description                                                                                                         | Documentation                                  | Status |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------ |
| [flutter_coverage_updater] | A Flutter coverage updater that generates coverage reports, HTML files, and SVG badges with cross-platform support. | [Documentation][flutter_coverage_updater_docs] | ✅      |
| [bump_release]             | Automated version bumping and release creation using git-cliff for semantic versioning                              | [Documentation][bump_release_docs]             | ✅      |

## 🚀 Quick Start

1. Install [Mason CLI](https://github.com/felangel/mason)
2. Add desired bricks to your project:
   ```bash
   # For Flutter coverage reporting
   mason add flutter_coverage_updater
   
   # For automated releases with semantic versioning
   mason add bump_release
   ```
3. Generate and enjoy!
   ```bash
   mason make flutter_coverage_updater
   # or
   mason make bump_release
   ```

## 🤝 Contributing

Contributions are welcome! Feel free to contribute new bricks or improvements to existing ones.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[coverage_badge]: coverage_badge.svg
[flutter_coverage_updater]: https://github.com/egortabula/egortabula_scripts/tree/main/flutter_coverage_updater
[flutter_coverage_updater_docs]: https://github.com/egortabula/egortabula_scripts/tree/main/flutter_coverage_updater/README.md
[bump_release]: https://github.com/egortabula/egortabula_scripts/tree/main/bump_release
[bump_release_docs]: https://github.com/egortabula/egortabula_scripts/tree/main/bump_release/README.md
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
