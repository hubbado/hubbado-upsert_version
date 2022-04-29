# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

# [2.0.0 - 2022-04-26]
## Changed
- Due to Rails 7 breaking attr_encrypted and replacing it with it's own encryption we decided to move to `lockbox` gem for encryption. It is very different from previous approach, as it hold only 1 field in the database.

# [1.1.2 - 2021-08-13]
- Fix case when encrypted_attributes are available in the model but none of them was included in the changed attributes

# [1.1.1 - 2021-08-12]
## Changed
- Replaced `pg_tester` with `standalone_migrations` due to lack of common support of `pg` between `pg_tester` and `activerecord`. It has changed the approach to testing and requires additional db setup prior.

# [1.0.1 - 2021-04-27]
## Changed
- Use github packages as gem source for our own gems

# [1.0.0] - 2020-01-02
### Added
- First version of gem extracted from the monolith
