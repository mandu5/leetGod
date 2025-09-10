#!/bin/bash

# 🧪 Test Runner Script for Leet God Project
# This script runs all tests for both backend and frontend

set -e  # Exit on any error

echo "🚀 Starting Leet God Test Suite"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the project root
if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Parse command line arguments
RUN_BACKEND=true
RUN_FRONTEND=true
RUN_E2E=false
VERBOSE=false
COVERAGE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)
            RUN_FRONTEND=false
            RUN_E2E=false
            shift
            ;;
        --frontend-only)
            RUN_BACKEND=false
            RUN_E2E=false
            shift
            ;;
        --e2e)
            RUN_E2E=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --backend-only    Run only backend tests"
            echo "  --frontend-only   Run only frontend tests"
            echo "  --e2e            Run end-to-end tests"
            echo "  --verbose        Enable verbose output"
            echo "  --coverage       Generate coverage reports"
            echo "  --help           Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Backend Tests
if [ "$RUN_BACKEND" = true ]; then
    print_status "Running Backend Tests..."
    echo "--------------------------------"
    
    cd backend
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        print_warning "Virtual environment not found. Creating one..."
        python -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing backend dependencies..."
    pip install -r requirements.txt
    if [ -f "requirements-dev.txt" ]; then
        pip install -r requirements-dev.txt
    fi
    
    # Run tests
    if [ "$COVERAGE" = true ]; then
        print_status "Running backend tests with coverage..."
        pytest tests/ -v --cov=. --cov-report=html --cov-report=term
    else
        print_status "Running backend tests..."
        if [ "$VERBOSE" = true ]; then
            pytest tests/ -v -s
        else
            pytest tests/ -v
        fi
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Backend tests passed!"
    else
        print_error "Backend tests failed!"
        exit 1
    fi
    
    cd ..
    echo ""
fi

# Frontend Tests
if [ "$RUN_FRONTEND" = true ]; then
    print_status "Running Frontend Tests..."
    echo "--------------------------------"
    
    cd frontend
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Run tests
    print_status "Running Flutter tests..."
    if [ "$COVERAGE" = true ]; then
        flutter test --coverage
        print_status "Coverage report generated in coverage/lcov.info"
    else
        if [ "$VERBOSE" = true ]; then
            flutter test --verbose
        else
            flutter test
        fi
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Frontend tests passed!"
    else
        print_error "Frontend tests failed!"
        exit 1
    fi
    
    cd ..
    echo ""
fi

# E2E Tests
if [ "$RUN_E2E" = true ]; then
    print_status "Running End-to-End Tests..."
    echo "--------------------------------"
    
    # Check if both backend and frontend are running
    print_status "Checking if services are running..."
    
    # Start backend if not running
    if ! curl -f http://localhost:8000/health &> /dev/null; then
        print_warning "Backend not running. Starting backend..."
        cd backend
        source venv/bin/activate
        python -m uvicorn main:app --host 0.0.0.0 --port 8000 &
        BACKEND_PID=$!
        cd ..
        
        # Wait for backend to start
        sleep 5
    fi
    
    # Start frontend if not running
    if ! curl -f http://localhost:3001 &> /dev/null; then
        print_warning "Frontend not running. Starting frontend..."
        cd frontend
        flutter run -d chrome --web-port=3001 &
        FRONTEND_PID=$!
        cd ..
        
        # Wait for frontend to start
        sleep 10
    fi
    
    # Run E2E tests
    print_status "Running E2E tests..."
    cd frontend
    flutter test integration_test/
    
    if [ $? -eq 0 ]; then
        print_success "E2E tests passed!"
    else
        print_error "E2E tests failed!"
        exit 1
    fi
    
    cd ..
    
    # Cleanup
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID
    fi
    
    echo ""
fi

# Summary
echo "================================="
print_success "All tests completed successfully! 🎉"
echo ""

if [ "$COVERAGE" = true ]; then
    print_status "Coverage reports generated:"
    if [ "$RUN_BACKEND" = true ]; then
        echo "  - Backend: backend/htmlcov/index.html"
    fi
    if [ "$RUN_FRONTEND" = true ]; then
        echo "  - Frontend: frontend/coverage/lcov.info"
    fi
fi

echo ""
print_status "Test Summary:"
if [ "$RUN_BACKEND" = true ]; then
    echo "  ✅ Backend tests: PASSED"
fi
if [ "$RUN_FRONTEND" = true ]; then
    echo "  ✅ Frontend tests: PASSED"
fi
if [ "$RUN_E2E" = true ]; then
    echo "  ✅ E2E tests: PASSED"
fi

echo ""
print_success "Leet God Test Suite completed! 🚀"
