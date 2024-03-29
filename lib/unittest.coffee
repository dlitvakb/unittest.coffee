class AssertionError
  constructor: (message) ->
    @message = message

class AssertionPass
  constructor: () ->
    @value = '.'

  log: () ->
    return

class AssertionFail
  constructor: (method_name, message, logger) ->
    @value = 'F'
    @method_name = method_name
    @message = message
    @logger = logger

  log: () ->
    @logger.log("#{@method_name}: #{@message}")

class AssertionExecutionError
  constructor: (method_name, stacktrace, logger) ->
    @value = 'E'
    @method_name = method_name
    @stacktrace = stacktrace
    @logger = logger

  log: () ->
    @logger.log("#{@method_name}: #{@stacktrace}")

class DefaultLogger
  constructor: () ->
    @results = []

  success: () ->
    @results.push(new AssertionPass())

  failure: (name, error) ->
    @results.push(new AssertionFail(name, error.message, this))

  error: (name, error) ->
    @results.push(new AssertionExecutionError(name, error.stack, this))

  dump_results: (time, assertions) ->
    amount = 0
    for result in @results
      result.log()
      amount += 1

    @log()
    @log("Results: #{(result.value for result in @results).join('')}")
    @log()
    @log("Done. #{amount} tests with #{assertions} assertions in #{time / 1000} seconds.")

  log: (args...) ->
    console.log(args...)

class TestCase
  constructor: (logger=new DefaultLogger()) ->
    @__assertions = 0
    @__logger = logger

  class_setup: () ->
    return

  setup: () ->
    return

  teardown: () ->
    return

  class_teardown: () ->
    return

  _assertion: (message, condition) ->
    @__assertions += 1
    throw new AssertionError(message) if not condition

  assertEquals: (message, expected, expectee) ->
    @_assertion(
      "#{message} - should be '#{expected}' but was '#{expectee}'",
      expected is expectee
    )

  assertTrue: (message, statement) ->
    @_assertion(message, statement)

  assertFalse: (message, statement) ->
    @_assertion(message, not statement)

  assertNull: (message, object) ->
    @_assertion(message, object isnt null)

  _is_test: (method_name) ->
    return /test_\w+/.test method_name

  run: () ->
    time = new Date()

    @class_setup()

    for method of this
      if not @_is_test method
        continue

      @setup()

      try
        this[method]()

        @__logger.success()
      catch e
        if e instanceof AssertionError
          @__logger.failure(method, e)
        else
          @__logger.error(method, e)

      @teardown()

    @class_teardown()

    @__logger.dump_results(new Date() - time, @__assertions)
    @assertions = 0

class TestSuite
  constructor: (logger=new DefaultLogger()) ->
    @__logger = logger

  _is_suite: (attr) ->
    return /suite_\w+/.test attr

  _run_suite: (suite_name) ->
    @__logger.log("Running #{this[suite_name].name} suite")
    new this[suite_name]().run()

  run: () ->
    for attr of this
      if not @_is_suite attr
        continue
      try
        @_run_suite attr
      catch e
        @__logger.log(e)
        throw e

exports.TestSuite = TestSuite
exports.TestCase = TestCase
exports.AssertionError = AssertionError
exports.AssertionPass = AssertionPass
exports.AssertionFail = AssertionFail
exports.AssertionExecutionError = AssertionExecutionError
exports.DefaultLogger = DefaultLogger
