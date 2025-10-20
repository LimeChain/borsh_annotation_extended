# Borsh Annotation Extended - Development Commands

# Run all tests
test:
    dart test

# Run tests with coverage collection
test-coverage:
    dart test --coverage=coverage

# Generate HTML coverage report
coverage: test-coverage
    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
    genhtml coverage/lcov.info -o coverage/html --quiet
    @echo "Coverage report generated at coverage/html/index.html"

# Open coverage report in browser (macOS)
coverage-open: coverage
    open coverage/html/index.html

# Clean coverage data
coverage-clean:
    rm -rf coverage/

# Run code analysis
analyze:
    dart analyze --fatal-infos

# Format code
format:
    dart format .

# Run all quality checks
check: analyze test-coverage
    @echo "All quality checks passed!"

# Install dependencies
deps:
    dart pub get

# Generate code (if using build_runner)
generate:
    dart run build_runner build

# Clean and regenerate everything
clean: coverage-clean
    dart pub get
    dart run build_runner clean
    dart run build_runner build

# Show help
help:
    @just --list