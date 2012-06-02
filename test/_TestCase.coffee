unittest = require '../lib/unittest'

class NonConsoleLogger extends unittest.DefaultLogger
  log: (args...) ->
    return

class TestCaseWithOnePassingTest extends unittest.TestCase
  test_that_passes: () ->
    @assertTrue('should be true', true)

class TestCaseWithOneFailingTest extends unittest.TestCase
  test_that_fails: () ->
    @assertTrue('should be true', false)

class TestCaseTest extends unittest.TestCase
  test_unittest_passes: () ->
    test = new TestCaseWithOnePassingTest(new NonConsoleLogger())
    test.run()
    @assertEquals(1, test.logger.results.size)
    @assertEquals('should have passed', '.', test.logger.results[0].value)

  test_unittest_fails: () ->
    test = new TestCaseWithOneFailingTest(new NonConsoleLogger())
    test.run()
    @assertEquals(1, test.logger.results.size)
    @assertEquals('should have failed', 'F', test.logger.results[0].value)

new TestCaseTest().run()
