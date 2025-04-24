# problem

[![Package Version](https://img.shields.io/hexpm/v/problem)](https://hex.pm/packages/problem)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/problem/)

An Error Handling library for Gleam. Inspired by
<https://github.com/lpil/snag> but with your own error type.

Problem gives you:

- An error stack that makes it easier to track the path of an error.
- Use your error type (instead of `String`).

```sh
gleam add problem
```

```gleam
import gleam/function
import problem.{type Outcome}

fn run_program(email) {
  case signup(email) {
    Error(problem) -> {
      problem
      |> problem.pretty_print(function.identity)
      |> echo
    }
    Ok(user) -> {
      todo
    }
  }
}

fn signup(email: String) -> Outcome(User, String) {
  use valid_email <- result.try(
    validate_email(email)
    |> problem.context("in signup")
  )

  todo
}

fn validate_email(email: String) -> Outcome(String, String) {
  Error("Invalid email")
    |> problem.outcome
    |> problem.context("in validate_email")
}
```

```text
run_program("invalid email")

Invalid email

stack:
  in validate_email
  in signup
```
