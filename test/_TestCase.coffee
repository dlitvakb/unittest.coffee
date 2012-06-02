unittest = require '../lib/unittest'

class NonConsoleLogger extends unittest.DefaultLogger
  log: (args...) ->
    return

class TestWithMoreThanOneTest extends unittest.TestCase
  test_that_passes: () ->
    @assertTrue('should be true', true)

  test_that_fails: () ->
    @assertTrue('should be true', false)

  test_with_errors: () ->
    undefined.fail()

class TestCaseTest extends unittest.TestCase
  test_more_than_one_unittest: () ->
    test = new TestWithMoreThanOneTest(new NonConsoleLogger())
    test.run()
    @assertEquals('should have passed', '.', test.logger.results[0].value)
    @assertEquals('should have failed', 'F', test.logger.results[1].value)
    @assertEquals('should have errors', 'E', test.logger.results[2].value)

new TestCaseTest().run()
