"""
Simple tests that should always pass.
"""

def test_math():
    """Test basic math."""
    assert 1 + 1 == 2
    assert 2 * 2 == 4
    assert 10 - 5 == 5

def test_string():
    """Test basic string operations."""
    assert "hello" == "hello"
    assert len("test") == 4
    assert "world" in "hello world"

def test_list():
    """Test basic list operations."""
    items = [1, 2, 3]
    assert len(items) == 3
    assert 2 in items
    assert items[0] == 1

def test_dict():
    """Test basic dictionary operations."""
    data = {"key": "value"}
    assert "key" in data
    assert data["key"] == "value"

def test_boolean():
    """Test boolean operations."""
    assert True is True
    assert False is False
    assert not False is True
