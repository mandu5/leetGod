"""
Unit tests for authentication service.
"""

def test_basic_import():
    """Test that auth service can be imported."""
    try:
        from services.auth_service import AuthService
        assert True
    except ImportError:
        assert False, "AuthService could not be imported"

def test_auth_service_instantiation():
    """Test AuthService can be instantiated."""
    try:
        from services.auth_service import AuthService
        auth_service = AuthService()
        assert auth_service is not None
    except Exception as e:
        assert False, f"AuthService instantiation failed: {e}"

def test_auth_service_methods_exist():
    """Test that AuthService has required methods."""
    try:
        from services.auth_service import AuthService
        auth_service = AuthService()
        
        # Check that methods exist
        assert hasattr(auth_service, 'verify_password')
        assert hasattr(auth_service, 'get_password_hash')
        assert hasattr(auth_service, 'create_access_token')
        assert hasattr(auth_service, 'verify_token')
        assert hasattr(auth_service, 'create_user')
        assert hasattr(auth_service, 'authenticate_user')
        assert hasattr(auth_service, 'get_user_by_email')
        
        # Check that they are callable
        assert callable(auth_service.verify_password)
        assert callable(auth_service.get_password_hash)
        assert callable(auth_service.create_access_token)
        assert callable(auth_service.verify_token)
        assert callable(auth_service.create_user)
        assert callable(auth_service.authenticate_user)
        assert callable(auth_service.get_user_by_email)
        
    except Exception as e:
        assert False, f"AuthService method check failed: {e}"