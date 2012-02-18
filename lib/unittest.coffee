class AssertionError
    constructor: (message) ->
        @message = message

class Assert
    assertEquals: (message, expected, expectee) ->
        throw new AssertionError("#{message} - should be '#{expected}' but was '#{expectee}'") if expected isnt expectee

    assertTrue: (message, statement) ->
        throw new AssertionError(message) if not statement

    assertFalse: (message, statement) ->
        throw new AssertionError(message) if statement

    assertNull: (message, object) ->
        throw new AssertionError(message) if object is null

class TestCase
    run: () ->
        amount = 0
        time = new Date()
        test_results = ""
        for method of this
            if /test_\w+/.test method
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

exports.TestCase = TestCase
exports.Assert = Assert
exports.AssertionError = AssertionError
