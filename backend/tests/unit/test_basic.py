"""
Basic tests to ensure the test framework is working.
"""

def test_basic_math():
    """Test basic math operations."""
    assert 1 + 1 == 2
    assert 2 * 3 == 6
    assert 10 - 5 == 5

def test_basic_string():
    """Test basic string operations."""
    assert "hello" == "hello"
    assert len("test") == 4
    assert "world" in "hello world"

def test_basic_list():
    """Test basic list operations."""
    test_list = [1, 2, 3]
    assert len(test_list) == 3
    assert 2 in test_list
    assert test_list[0] == 1

def test_basic_dict():
    """Test basic dictionary operations."""
    test_dict = {"key": "value", "number": 42}
    assert "key" in test_dict
    assert test_dict["key"] == "value"
    assert test_dict["number"] == 42
