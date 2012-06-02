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

  dump_results: (time) ->
    amount = 0
    for result in @results
      result.log()
      amount += 1

    @log()
    @log("Results: #{(result.value for result in @results).join('')}")
    @log()
    @log("Done. #{amount} tests run in #{time / 1000} seconds.")

  log: (args...) ->
    console.log(args...)

class TestCase
  constructor: (logger=new DefaultLogger()) ->
    @logger = logger

  class_setup: () ->
    return

  setup: () ->
    return

  teardown: () ->
    return

  class_teardown: () ->
    return

  assertEquals: (message, expected, expectee) ->
    throw new AssertionError("#{message} - should be '#{expected}' but was '#{expectee}'") if expected isnt expectee

  assertTrue: (message, statement) ->
    throw new AssertionError(message) if not statement

  assertFalse: (message, statement) ->
    throw new AssertionError(message) if statement

  assertNull: (message, object) ->
    throw new AssertionError(message) if object is null

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

        @logger.success()
      catch e
        if e instanceof AssertionError
          @logger.failure(method, e)
        else
          @logger.error(method, e)

      @teardown()

    @class_teardown()

    @logger.dump_results(new Date() - time)

class TestSuite
  constructor: (logger=new DefaultLogger()) ->
    @logger = logger

  _is_suite: (attr) ->
    return /suite_\w+/.test attr

  _run_suite: (suite_name) ->
    @logger.log("Running #{this[suite_name].name} suite")
    new this[suite_name]().run()

  run: () ->
    for attr of this
      if not @_is_suite attr
        continue
      try
        @_run_suite attr
      catch e
        @logger.log(e)
        throw e

exports.TestSuite = TestSuite
exports.TestCase = TestCase
exports.AssertionError = AssertionError
exports.AssertionPass = AssertionPass
exports.AssertionFail = AssertionFail
exports.AssertionExecutionError = AssertionExecutionError
exports.DefaultLogger = DefaultLogger
