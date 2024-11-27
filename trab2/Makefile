# Compiler settings
CXX = g++
CXXFLAGS = -Wall -g

# Target executable name
TARGET = main

# Source files
SOURCES = main.cpp \
          globals.cpp \
          registers.cpp \
          instruction.cpp \
          acesso_memoria.cpp \
          simulator.cpp \
          decode.cpp

# Object files
OBJECTS = $(SOURCES:.cpp=.o)

# Default target
all: $(TARGET)

# Link the target executable
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(TARGET)

# Compile source files to object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up
clean:
	rm -f $(OBJECTS) $(TARGET)

# Rebuild everything
rebuild: clean all

# Help target
help:
	@echo "Available targets:"
	@echo "  make all     - Build the executable (default)"
	@echo "  make clean   - Remove object files and executable"
	@echo "  make rebuild - Clean and rebuild everything"
	@echo "  make help    - Show this help message"

.PHONY: all clean rebuild help
