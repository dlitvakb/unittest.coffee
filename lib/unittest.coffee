class AssertionError
  constructor: (message) ->
    @message = message

class TestCase

  assertEquals: (message, expected, expectee) ->
    throw new AssertionError("#{message} - should be '#{expected}' but was '#{expectee}'") if expected isnt expectee

  assertTrue: (message, statement) ->
    throw new AssertionError(message) if not statement

  assertFalse: (message, statement) ->
    throw new AssertionError(message) if statement

  assertNull: (message, object) ->
    throw new AssertionError(message) if object is null

  run: () ->
    amount = 0
    time = new Date()
    test_results = ""
    for method of this
      if not /test_\w+/.test method
        continue

      try
        this[method]()
        test_results += "."
      catch e
        if e instanceof AssertionError
          console.log("#{method}: #{e.message}")
          test_results += "F"
        else
          console.log(e)
      amount += 1

    time = new Date() - time
    console.log()
    console.log("Results: #{test_results}")
    console.log()
    console.log("Done. #{amount} tests run in #{time / 1000} seconds.")

class TestSuite

  run: () ->
    for attr of this
      if not /suite_\w+/.test attr
        continue
      try
        console.log("Running #{this[attr].name} suite")
        new this[attr]().run()
      catch e
        console.log(e)
        throw e

exports.TestSuite = TestSuite
exports.TestCase = TestCase
exports.AssertionError = AssertionError
