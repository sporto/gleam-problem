default:
	just --list

changelog:
	git cliff --output CHANGELOG.md

docs:
	gleam docs build

publish:
	gleam publish
