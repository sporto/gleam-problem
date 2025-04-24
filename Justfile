default:
	just --list

changelog:
	git cliff

docs:
	gleam docs build

publish:
	gleam publish
