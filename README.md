#UnitTest.coffee
###A Unit Testing framework for CoffeeScript

##Usage
```coffee
unittest = require 'unittest'

class FooTest extends unittest.TestCase
    test_foo: () ->
        @assertEquals("should be a foo", "foo", "bar")
        # this will fail with the message
        # "test_foo: should be a foo - expected 'foo' but was 'bar'"

    test_bar: () ->
        @assertTrue("should be true", true)

new FooTest().run()
```

Will run all the methods that start with 'test_' and this will produce the
following output:

```
test_foo: should be a foo - expected 'foo' but was 'bar'

Results: F.
Done. 2 tests run in 0.005 seconds.
```


