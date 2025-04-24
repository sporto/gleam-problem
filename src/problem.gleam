import gleam/list
import gleam/result
import gleam/string

/// A list of context entries
pub type ContextStack =
  List(String)

/// The error type in a result ie. `Result(t, Problem)`
pub type Problem(err) {
  Problem(error: err, stack: ContextStack)
}

pub type Outcome(t, err) =
  Result(t, Problem(err))

fn push_to_stack(stack: ContextStack, entry: String) -> List(String) {
  [entry, ..stack]
}

pub fn context(problem: Problem(err), value: String) -> Problem(err) {
  Problem(..problem, stack: push_to_stack(problem.stack, value))
}

/// Map the error value
pub fn map_error(
  outcome: Outcome(t, err),
  mapper: fn(err) -> err,
) -> Outcome(t, err) {
  result.map_error(outcome, problem_map_error(_, mapper))
}

fn problem_map_error(
  problem: Problem(err),
  mapper: fn(err) -> err,
) -> Problem(err) {
  Problem(..problem, error: mapper(problem.error))
}

/// Remove the `Problem` wrapping in the error value
///
/// ## Example
///
/// ```gleam
/// let outcome = Error("Fail") |> problem.outcome
///
/// problem.to_result(outcome) == Error("Fail")
/// ```
pub fn to_result(outcome: Outcome(t, err)) -> Result(t, err) {
  outcome |> result.map_error(fn(problem) { problem.error })
}

// *************************
// Print
// *************************

/// Pretty print a Problem, including the stack.
/// The latest problem appears at the top of the stack.
///
/// ## Example
///
/// ```gleam
/// Error("Something went wrong")
/// |> outcome.as_defect
/// |> outcome.context("In find user function")
/// |> outcome.context("More context")
/// |> outcome.pretty_print(function.identity)
/// ```
///
/// ```
/// Defect: Something went wrong
///
/// stack:
///  In find user function
///  More context
/// ```
pub fn pretty_print(problem: Problem(err), to_s: fn(err) -> String) -> String {
  pretty_print_with_joins(problem, "\n\nstack:\n  ", "\n  ", to_s)
}

/// Print problem in one line
///
/// ## Example
///
/// ```gleam
/// Error("Something went wrong")
/// |> outcome.as_defect
/// |> outcome.context("In find user function")
/// |> outcome.print_line(function.identity)
/// ```
///
/// ```
/// Defect: Something went wrong < In find user function
/// ```
pub fn print_line(problem: Problem(err), to_s: fn(err) -> String) -> String {
  pretty_print_with_joins(problem, " < ", " < ", to_s)
}

fn pretty_print_with_joins(
  problem: Problem(err),
  join_current: String,
  join_stack: String,
  to_s: fn(err) -> String,
) -> String {
  let current = to_s(problem.error)

  let stack =
    join_current
    <> problem.stack
    |> stack_to_lines
    |> string.join(join_stack)

  let stack = case problem.stack {
    [] -> ""
    _ -> stack
  }

  current <> stack
}

pub fn stack_to_lines(stack: ContextStack) -> List(String) {
  stack
  |> list.reverse
}
