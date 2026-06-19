# Ruby Conventions

Personal Ruby style. Favor declarative, expression-oriented code over imperative
temp-variable bookkeeping. Stdlib first, few gems. Build the layer below yourself
(Rack, the queue, the server) when the point is to understand it.

## Endless methods for one-expression bodies

Any method whose body is a single expression uses the endless form `def name = expr`.
Applies to predicates and `self.` factories too. This is the default, not the exception.

```ruby
def dispatch(request) = @router.dispatch(request)
def key                = "#{@verb} #{@path}"
def output_layer       = @layers.last
def self.sigmoid(n)    = 1 / (1 + Math.exp(-n))
```

Reach for `def ... end` only when the body needs more than one statement.

## Service objects: `self.call` → `new(...).call`

A use case is a class with a class-method entry point that delegates to an instance.
The instance implements two methods only: `initialize` to capture inputs, and the verb
(`call` / `result` / `run` / `build`) that holds the logic. Subclasses never redeclare
the factory.

```ruby
class BaseAction
  def self.call(*args) = new(*args).call
end

class RegisterAction < BaseAction
  def initialize(email, password, confirmation)
    @email = email; @password = password; @confirmation = confirmation
  end

  def call
    validate_password_match!
    @users_repository.create_user(@user)
  end
end
```

The class-method verb matches the instance verb (`build` → `.build`, `run` → `.run`).

## `tap` to mutate-and-return, `then` to pipe

Prefer `tap` to construct an object, run a setup/parse step, and return it in one
expression, over the imperative "assign, mutate, return" pattern.

```ruby
# Prefer
def self.parse(first_line, second_line)
  new(first_line, second_line).tap(&:parse)
end

# Over
def self.parse(first_line, second_line)
  parser = new(first_line, second_line)
  parser.parse
  parser
end
```

`tap` yields the receiver and returns it, ignoring the block's value. So the tapped
method (`parse`) does not need to `return self` — drop the trailing `self` and let it
be a pure command.

Use `then` (yield_self) to thread a value through a sequence of transforms, reading
top-to-bottom as a pipeline. Build whole request lifecycles or config loads this way:

```ruby
read_request_message(client)
  .then { |message|  Request.build(message) }
  .tap  { |request|  request.parse_body!(client) }
  .then { |request|  @rack_app.call(rack_data(request)) }
  .then { |result|   Response.build(*result) }
  .then { |response| client.puts(response) }
```

`tap` mutates and passes the receiver along; `then` transforms and passes the value.

## Dispatch with `case/in` pattern matching

Prefer `case/in` over `case/when` or `if/elsif` ladders when branching on the shape or
type of data. Tag sum-types with a `kind:` key and match hash patterns; use array
patterns with type guards for typed dispatch. One `in` per line, body inline, columns
aligned, always an `else` that raises.

```ruby
case term
in { kind: 'Bool', **data } then [:raw, data[:value], scope]
in { kind: 'Int',  **data } then [:raw, data[:value].to_i, scope]
in { kind: 'Let',  **data } then evaluate_let(data, scope)
else raise Error.new(location, "Unknown term: #{term}")
end

case [op, lhs, rhs]
in ['Add', Integer, Integer] then lhs + rhs
in ['Add', _, _]             then "#{lhs}#{rhs}"
in ['Lt',  Integer, Integer] then lhs < rhs
end
```

Actor inboxes follow the same shape: `loop { case @inbox.pop in deposit: amount ... }`.

## Hash tables over conditional ladders

Route, configure, and dispatch through frozen constant hashes keyed by value, not
through `if`/`case` chains. Look the key up, then `send` the result.

```ruby
ROUTES_TABLE = {
  'GET /'             => :get_homepage_route,
  'POST /login'       => :post_login_route,
  'DELETE /tasks/:id' => :delete_tasks_route
}.freeze

ADAPTERS = { postgres: PGDatabase, filesystem: FSDatabase }.freeze

def route(verb, path) = send(ROUTES_TABLE.fetch("#{verb} #{path}", :not_found))
```

## Idioms

- **Point-free blocks.** `&:symbol` for sends, `&method(:name)` (or
  `&Mod.method(:name)`) to pass a named method as a block. Prefer
  `.map(&method(:build_layer))` over `.map { |l| build_layer(l) }`.
- **Destructure, don't index repeatedly.** `values_at` / `dig` / multiple assignment /
  rightward `=>` over repeated `hash[:key]`:
  ```ruby
  op, lhs, rhs = data.values_at(:op, :lhs, :rhs)
  text         = data.dig(:name, :text)
  layer_data => [neurons, weights]
  ```
- **Memoize with `||=`** for lazy infra objects: `def queue = @queue ||= Queue.new`.
- **Naming discipline.** `?` for every predicate (`static_asset?`, `match?`). `!` for
  either mutation/side-effects (`parse_body!`, `add_param!`) or raise-on-failure
  validators (`validate_password_match!`). Never `!` just because the name "feels"
  dangerous.
- **`# frozen_string_literal: true`** as line 1 of library files. It's a library
  discipline; skip it in throwaway scripts and samples.
- **Numeric underscores** for large literals: `500_000`, `1_000`.

## Errors: thin classes, raise deep, rescue at the boundary

One error per file, an empty subclass of `StandardError`. Add a constructor only when
the error carries structured context.

```ruby
class UnauthorizedError < StandardError; end

class Error < StandardError
  def initialize(location, message)
    super(location ? "Error: #{message} at #{location[:filename]}" : "Error: #{message}")
  end
end
```

Raise domain errors deep in the use case; rescue them at the layer that maps to a
transport (controller → HTTP status, router → redirect). Don't rescue in between.

```ruby
rescue PasswordNotMatchError then render status: 401, body: 'Password do not match'
rescue UnauthorizedError     then redirect_to_login
```

Wrap-and-reraise with added context (`rescue => e; raise Error.new(loc, "...: #{e.message}")`).
`cond or raise ...` for inline assertions. Inline `rescue` modifier
(`JSON.parse(body) rescue {}`) only for genuinely best-effort paths. Model expected
failure as a return value (nil, a 404 object) rather than an exception where you can.

## Testing: Test::Unit, no mocking libs

`Test::Unit` (test-unit gem), not Minitest, not RSpec. Test classes mirror the source
namespace and tree. Methods are `test_<behavior>` in plain snake_case sentences — no
`describe`/`context`/`should`.

```ruby
class RegisterActionTest < Test::Unit::TestCase
  include UserFactory
  def setup = DB.connection.truncatedb

  def test_register_password_not_match
    assert_raise(PasswordNotMatchError) { RegisterAction.call('a@b.com', 'x', 'y') }
  end
end
```

- `assert_equal(expected, actual)`, expected first. `.round(n)` on the actual for floats.
- Test doubles are inline subclasses with `def initialize; end` and endless stub
  readers, or the `spy` gem. No heavyweight mocking framework.
- Factories are modules of bang methods (`create_user!(email:)`) using `tap`,
  `include`d into the test case.
- Suite entry is a loader, not Rake: `Dir['./test/**/*.rb'].sort.each { |f| require f }`,
  run via `ruby -Itest test/all.rb`.

## Dependencies & tooling

- **Minimal Gemfile, no Rails.** Hand-roll Rack apps, request/response, template
  engines, queues, servers on raw stdlib (`socket`, `json`, `stringio`, `Thread`,
  `Queue`, `Ractor`). Add a gem only when stdlib genuinely falls short (`pg`, `bcrypt`,
  `rack`, `oj`).
- **Makefile + `bin/` scripts over Rake.** Self-documenting `make help`; thin shell-outs
  (often Docker-wrapped) for test/server/bench targets.
- **RuboCop present but light.** Only disable mandatory class docs globally; bracket a
  genuinely non-conforming file with `# rubocop:disable all` rather than weakening the
  config for everyone.

## Concurrency

- **Spawn-collect in one chained expression**, same shape across primitives:
  `N.times.map { primitive }.each(&:join)` (Thread), `.each(&:take)` (Ractor),
  `.each(&:resume)` (Fiber).
- **Pass captured values as thread/ractor args**, re-bound as block params, to avoid
  closure-capture bugs: `Thread.new(i + 1) { |id| handle(id) }`.
- **Server shape:** accept-loop in the main thread pushes clients onto a `Queue`; a fixed
  pool of workers pops it. Graceful shutdown via `throw :exit` poison pills caught by
  `catch(:exit)`, not flags.
- **Hand-rolled queue** when teaching the primitive: `Mutex#synchronize` +
  `ConditionVariable#wait` in a `while empty?` loop.
- **Rescue specific concurrency exceptions** (`Ractor::RemoteError`, `IO::WaitReadable`,
  `EOFError`), never bare `rescue`. Clean up resources with explicit `.close` on the
  happy path and `trap("INT")`/`trap("EXIT")` for signals, not `ensure`.
