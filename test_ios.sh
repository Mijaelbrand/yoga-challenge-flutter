#!/bin/bash

echo "🧪 Starting iOS Testing for Yoga Challenge App"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter is installed"

# Check Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Installing dependencies..."
flutter pub get

# Generate code
print_status "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Install iOS dependencies
print_status "Installing iOS dependencies..."
cd ios
pod install
cd ..

# Run unit and widget tests
print_status "Running unit and widget tests..."
flutter test

# Check if tests passed
if [ $? -eq 0 ]; then
    print_status "All tests passed!"
else
    print_error "Some tests failed!"
    exit 1
fi

# Check available devices
echo "📱 Available devices:"
flutter devices

# Ask user for testing preference
echo ""
echo "Choose testing option:"
echo "1. Run on iOS Simulator"
echo "2. Build for iOS device"
echo "3. Build for TestFlight"
echo "4. Run performance tests"
echo "5. All of the above"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_status "Running on iOS Simulator..."
        flutter run -d ios
        ;;
    2)
        print_status "Building for iOS device..."
        flutter build ios --release
        print_status "iOS build completed! Check build/ios/iphoneos/Runner.app"
        ;;
    3)
        print_status "Building for TestFlight..."
        flutter build ipa --release
        print_status "TestFlight build completed! Check build/ios/ipa/"
        ;;
    4)
        print_status "Running performance tests..."
        flutter run -d ios --profile --trace-startup
        ;;
    5)
        print_status "Running comprehensive iOS testing..."
        
        # Run on simulator
        print_status "1. Testing on iOS Simulator..."
        flutter run -d ios &
        SIMULATOR_PID=$!
        
        # Wait a bit then stop simulator
        sleep 30
        kill $SIMULATOR_PID 2>/dev/null
        
        # Build for device
        print_status "2. Building for iOS device..."
        flutter build ios --release
        
        # Build for TestFlight
        print_status "3. Building for TestFlight..."
        flutter build ipa --release
        
        # Performance test
        print_status "4. Running performance tests..."
        flutter run -d ios --profile --trace-startup &
        PERF_PID=$!
        sleep 30
        kill $PERF_PID 2>/dev/null
        
        print_status "All iOS testing completed!"
        ;;
    *)
        print_error "Invalid choice!"
        exit 1
        ;;
esac

echo ""
print_status "iOS testing completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Test the app on physical iOS devices"
echo "2. Upload to TestFlight for beta testing"
echo "3. Submit to App Store for review"
echo ""
echo "📚 Useful commands:"
echo "- flutter run -d ios                    # Run on iOS Simulator"
echo "- flutter build ios --release          # Build for device"
echo "- flutter build ipa --release          # Build for TestFlight"
echo "- flutter test --coverage              # Run tests with coverage"
echo "- flutter analyze                      # Analyze code"
echo ""
