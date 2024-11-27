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


